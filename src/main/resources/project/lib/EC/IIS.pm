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
use base qw(Exporter);
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
    my ($self, @args) = @_;

    croak "No command to execute"
        unless $args[0];

    my $cmd = $self->printable_cmdline(@args);
    print "Executing: $cmd";

    local $!;
    my $ret = system $cmd;
    if ($!) {
        croak "Cannot execute '$args[0]': $!";
    } else {
        $ret >>= 8;
    };

    $self->setProperties({cmdLine => $cmd}); # TODO what if >1  commands?..

    return $ret;
};

sub read_cmd {
    my ($self, @args) = @_;

    croak "No command to execute"
        unless $args[0];

    my $cmd = $self->printable_cmdline(@args);
    print "Reading output from: $cmd";

    local $!;
    my $pid = open( my $fd, "-|", $cmd)
        or croak "Failed to execute '$args[0]': $!";

    local $/;
    my $data = <$fd>;
    waitpid($pid, 0);
    my $status = $? >> 8;

    $self->setProperties({cmdLine => $cmd}); # TODO what if >1  commands?..

    return wantarray ? ($data, $status) : $data;
};

sub run_reset {
    my ($self, @args) = @_;

    my $ret = $self->run_cmd( $self->iisreset, @args );

    if ($ret) {
        print "iisreset ".$self->iisreset." failed with exit status $ret\n";
    };

    return $ret;
};

sub iisreset {
    return 'iisreset'; #TODO configurable
};

sub printable_cmdline {
    my ($self, @args) = @_;

    # We know for sure that password (if any) follows the /p flag
    my $is_password;
    foreach (@args) {
        if ($is_password) {
            $_ = '*****';
            last;
        };
        $is_password++ if $_ eq '/p';
    };

    return join ' ', map {
        /[^\w\/\\\.]/ ? qq{"$_"} : $_; # TODO escape \'s?..
    } @args;

    
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

1;
