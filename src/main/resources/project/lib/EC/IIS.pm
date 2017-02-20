#
#  Copyright 2017 Electric Cloud, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

package EC::IIS;

use strict;
use warnings;

=head1 NAME

EC::IIS - Electric Commander Microsoft IIS integration plugin core.

=cut

use Carp;
use File::Temp qw(tempfile);
require Win32 if $^O eq 'MSWin32';
use EC::Plugin::Core;
use base qw(Exporter EC::Plugin::Core);
our @EXPORT_OK = qw(trim);

use ElectricCommander;
use ElectricCommander::PropDB;

use constant {
    SUCCESS => 0,
    ERROR   => 1,

    PLUGIN_NAME => 'EC-IIS',
    CREDENTIAL_ID => 'credential',
    CHECK_COMMAND => '/status',

    GENERATE_REPORT => 1,
    DO_NOT_GENERATE_REPORT => 0,

    # IIS7 defaults
    DEFAULT_APPCMD_PATH => ($ENV{windir} || 'C:\\').'\system32\inetsrv\appcmd',

};

sub new {
    my ($class, %opt) = @_;

    $opt{ec} ||= ElectricCommander->new;
    return bless \%opt, $class;
};

sub get_ec {
    my $self = shift;
    return $self->{ec};
};

sub trim {
    my ($string) = shift;

    # kill leading & trailing spaces
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
};

sub run_cmd {
    my ($self, $args, %opt) = @_;

    croak "No command to execute"
        unless $args->[0];

    my $cmd = $self->printable_cmdline($args);
    my $cmd_show = $self->printable_cmdline($args, %opt);
    print "Executing: $cmd_show\n";

    local $!;
    my $ret = system $cmd;
    if ($!) {
        croak "Cannot execute '$args->[0]': $!";
    } else {
        $ret >>= 8;
    };

    $self->setProperties({cmdLine => $cmd_show}); # TODO what if >1  commands?..

    return $ret;
};

sub read_cmd {
    my ($self, $args, %opt) = @_;

    croak "read_cmd(): First argument MUST be an arrayref"
        unless ref $args eq 'ARRAY';
    croak "read_cmd(): No command to execute"
        unless $args->[0];

    my $cmd = $self->printable_cmdline($args);
    my $cmd_show = $self->printable_cmdline($args, %opt);
    print Carp::shortmess("Reading output from: $cmd_show");

    local $!;
    my $pid = open( my $fd, "-|", $cmd)
        or croak "Failed to execute '$args->[0]': $!";

    local $/;
    my $data = <$fd>;
    waitpid($pid, 0);
    my $status = $? >> 8;

    if ($status) {
        print Carp::shortmess("Command exited with status $status");
    };

    $self->setProperties({cmdLine => $cmd_show}); # TODO what if >1  commands?..

    return wantarray ? ($data, $status) : $data;
};

sub run_cscript_js {
    my ($self, $src) = @_;

    my ( $scriptfh, $scriptfilename ) = tempfile( DIR => '.', SUFFIX => '.js' );

    print $scriptfh $src;
    close($scriptfh);

    return $self->run_cmd( [ cscript => '/E:jscript', '/NoLogo', $scriptfilename ] );
};

sub run_reset {
    my ($self, $args) = @_;

    $args = [ $args ] unless ref $args eq 'ARRAY'; # just 1 arg
    my $ret = $self->run_cmd( [ $self->iisreset, @$args ] );

    if ($ret) {
        print "iisreset ".$self->iisreset." failed with exit status $ret\n";
    };

    return $ret;
};

sub iisreset {
    return 'iisreset'; #TODO configurable
};

sub cmd_appcmd {
    return DEFAULT_APPCMD_PATH;
};

sub printable_cmdline {
    my ($self, $args, %opt) = @_;

    # We know for sure that password (if any) follows the /p flag
    my $is_password;
    my @safe;
    foreach (@$args) {
        if ($is_password) {
            push @safe, '*****';
            $is_password = 0;
            next;
        };
        $is_password++ if $opt{password_after} and $_ eq $opt{password_after};
        push @safe, $_;
    };

    return join ' ', map {
        /[^\w\/\\\.]/ ? qq{"$_"} : $_; # TODO escape \'s?..
    } @safe;
};

my @version = ($^O eq 'MSWin32') ? Win32::GetOSVersion() : ();

sub iis_version {
    # TODO add better autodetection
    # For now, 6/7 division is the most crucial.
    croak "EC::IIS: Not a Windows system, aborting!"
        unless @version;
    return $version[1] >= 6 ? 7 : 6;

    # Here's the table:

    # OS                        ID  MAJOR   MINOR   IIS
    # Win32s                    0   -       -       ?
    # Windows 95                1   4       0       ?
    # Windows 98                1   4       10      ?
    # Windows Me                1   4       90      ?
    #
    # Windows NT 3.51           2   3       51      ?
    # Windows NT 4              2   4       0       ?
    #
    # Windows 2000              2   5       0       5
    # Windows XP                2   5       1       5
    # Windows Server 2003       2   5       2       6
    # Windows Server 2003 R2    2   5       2       6
    # Windows Home Server       2   5       2       ?
    #
    # Windows Vista             2   6       0       ?
    # Windows Server 2008       2   6       0       7
    # Windows 7                 2   6       1       7
    # Windows Server 2008 R2    2   6       1       7 || 7.5
    # Windows 8                 2   6       2       ?
    # Windows Server 2012       2   6       2       ?
};

sub outcome_error {
    my ($self, $fail) = @_;

    # TODO Add error details? do  we need it at all?
    return $self->{ec}->setProperty( "/myJobStep/outcome", $fail ? 'error' : 'success' );
};

sub get_site_id {
    my ($self, $name) = @_;

    if ($self->iis_version < 7) {
        croak "get_site_id() unimplemented on IIS v.".$self->iis_version;
    };
    my ($content, $ret) = $self->read_cmd(
        [ $self->cmd_appcmd => list => site => "/name:$name" ] );
    croak "get_site_id(): Failed to execute ".$self->cmd_appcmd.": ret $ret, output was $content"
        if $ret;

    print "Got this: $content\n";
    $content =~ m#id:(\d+)#;
    return $1;
};

########################################################################
# setProperties - set a group of properties into the Electric Commander
#
# Arguments:
#   -propHash: hash containing the ID and the value of the properties
#              to be written into the Electric Commander
#
# Returns:
#   none
#
########################################################################
sub setProperties {
    my ($self, $propHash) = @_;

    # get an EC object
    my $ec = $self->{ec};

    foreach my $key (keys %$propHash) {
        my $val = $propHash->{$key};
        $ec->setProperty("/myCall/$key", $val);
    };
}

sub getConfiguration($){
    my ($self, $configName) = @_;

    # get an EC object
    my $ec = $self->{ec};

    my %configToUse;

    my $proj = "$[/myProject/projectName]";
    my $pluginConfigs = new ElectricCommander::PropDB($ec,"/projects/$proj/iis_cfgs");

    my %configRow = $pluginConfigs->getRow($configName);

    # Check if configuration exists
    unless(keys(%configRow)) {
        croak "No config for '$proj' named '$configName'";
    }

    # Get user/password out of credential
    my $xpath = $ec->getFullCredential($configRow{credential});
    $configToUse{'user'} = $xpath->findvalue("//userName");
    $configToUse{'password'} = $xpath->findvalue("//password");

    foreach my $c (keys %configRow) {
        #getting all values except the credential that was read previously
        if($c ne CREDENTIAL_ID){
            $configToUse{$c} = $configRow{$c};
        }
    }

    return \%configToUse;
}

sub create_msdeploy_command {
    my ($self, $params) = @_;

    my $exec = EC::Plugin::Core::canon_path($params->{msdeployPath});
    my $command = "\"$exec\" -verb:$params->{verb}";

    $command .= " -source:$params->{sourceProvider}";
    if ($params->{sourceProviderObjectPath}) {
        my $path = EC::Plugin::Core::canon_path($params->{sourceProviderObjectPath});
        $command .= qq{="$path"};
    }
    if ($params->{sourceProviderSettings}) {
        $command .= ",$params->{sourceProviderSettings}";
    }
    $command .= " -dest:$params->{destProvider}";
    if ($params->{destProviderObjectPath}) {
        my $path = EC::Plugin::Core::canon_path($params->{destProviderObjectPath});
        $command .= qq{="$path"};
    }
    if ($params->{destProviderSettings}) {
        $command .= ",$params->{destProviderSettings}";
    }
    if ($params->{allowUntrusted}) {
        $command .= " -allowUntrusted";
    }
    if ($params->{postSync}) {
        $command .= " -postSync:\"$params->{postSync}\"";
    }
    if ($params->{preSync}) {
        $command .= " -preSync:\"$params->{preSync}\"";
    }
    if ($params->{setParamFile}) {
        if (_is_xml($params->{setParamFile}) && $params->{setParamFile} =~ m/parameters/) {
            my $filename = _save_params_file($params->{setParamFile});
            $command .= " -setParamFile:$filename";
        }
        elsif (-f $params->{setParamFile}) {
            $command .= " -setParamFile:$params->{setParamFile}";
        }
        else {
            $self->bail_out("The file $params->{setParamFile} is not found");
        }
    }
    if ($params->{declareParamFile}) {
        if (_is_xml($params->{declareParamFile}) && $params->{declareParamFile} =~ m/parameters/) {
            my $filename = _save_params_file($params->{declareParamFile});
            $command .= " -declareParamFile:$filename";
        }
        elsif (-f $params->{declareParamFile}) {
            $command .= " -declareParamFile:$params->{declareParamFile}";
        }
        else {
            $self->bail_out("The file $params->{declareParamFile} is not found");
        }
    }
    if ($params->{additionalOptions}) {
        $command .= " $params->{additionalOptions}";
    }
    return $command;
}

sub set_cmd_line {
    my ($self, $cmd_line) = @_;

    $self->get_ec->setProperty('/myCall/cmdLine', $cmd_line);
}

sub _is_xml {
    my ($content) = @_;

    return $content =~ m/[<>]/;
}

sub _save_params_file {
    my ($content) = @_;

    my $filename = "param_file_" . EC::Plugin::Core::gen_random_numbers(42) . ".xml";
    open my $fh, ">" . $filename or die "Cannot open file $filename: $!";
    print $fh $content;
    close $fh;
    return $filename;
}

1;
