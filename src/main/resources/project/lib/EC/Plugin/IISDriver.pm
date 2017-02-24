package EC::Plugin::IISDriver;

use strict;
use warnings;
use EC::Plugin::Core;
use base qw(EC::Plugin::Core);

use constant {
    DEFAULT_APPCMD_PATH => ($ENV{windir} || 'C:\\').'\system32\inetsrv\appcmd',
};

sub cmd_appcmd {
    return DEFAULT_APPCMD_PATH;
};


sub get_app_pool {
    my ($self, $website, $application) = @_;

    my $command = $self->get_app_cmd('list', 'apps', qq{/app.name:"$website/$application"});
    my $result = $self->run_command($command);

    if ($result->{stdout}) {
        # APP "testsite/app" (applicationPool:mypool)
        my ($pool) = $result->{stdout} =~ m/APP ".+" \(applicationPool:(.+)\)/;
        return $pool;
    }
    return;
}

sub check_app_pool_exists {
    my ($self, $name) = @_;

    my $check_exists_command = $self->get_app_cmd('list', 'apppools', qq{/name:"$name"});
    my $result = $self->run_command($check_exists_command);
    if ($result->{stderr} ne '') {
        return $self->bail_out("Cannot list app pools: $result->{stderr}");
    }
    return $result->{stdout} ? 1 : 0;
}


sub create_app_cmd {
    my ($self, $params) = @_;

    my $site_name = $params->{websiteName} or die 'No site name';
    my $path = $params->{applicationPath} or die 'No application path';
    my $physical_path = $params->{physicalPath} or die 'No physicalPath';

    $physical_path = EC::Plugin::Core::canon_path($physical_path);
    # TODO create folder if it does not exists

    if ($path !~ m/^\//) {
        $path = "/$path";
    }

    my $command = $self->get_app_cmd(
        'add', 'app',
        qq{/site.name:"$site_name"},
        qq{/path:"$path"},
        qq{/physicalPath:"$physical_path"}
    );
    return $command;
}

my @app_pool_settings = qw(managedRuntimeVersion enable32BitAppOnWin64 managedPipelineMode queueLength autoStart);

sub create_app_pool_cmd {
    my ($self, $params, $available_settings) = @_;

    if (!$available_settings || !@$available_settings) {
        $available_settings = [ @app_pool_settings ];
    }

    my $name = $params->{applicationPool};
    unless($name) {
        return $self->bail_out("No application pool name");
    }
    my @settings = ();

    for my $setting ( @$available_settings ) {
        if ($params->{$setting}) {
            push @settings, qq{/$setting:"$params->{$setting}"};
        }
    }

    if ($params->{appPoolAdditionalSettings}) {
        push @settings, $params->{appPoolAdditionalSettings};
    }

    my $command = $self->get_app_cmd('add', 'apppool', qq{/name:"$name"}, @settings);
    return $command;
}

sub delete_app_cmd {
    my ($self, $params) = @_;

    my $app_name = $params->{applicationName};
    my $command = $self->get_app_cmd(
        'delete', 'app',
        qq{/app.name:"$app_name"}
    );
    return $command;
}

sub get_app_cmd {
    my ($self, $action, $object, @params) = @_;

    my $executable = $self->cmd_appcmd;
    die 'No action' unless $action;
    die 'No object' unless $object;
    my $command = "\"$executable\" $action $object " . join(" ", @params);
    return $command;
}

sub update_app_pool_cmd {
    my ($self, $params, $available_settings) = @_;

    if (!$available_settings || !@$available_settings) {
        $available_settings = [ @app_pool_settings ];
    }

    my $name = $params->{applicationPool};
    my @settings = ();

    for my $setting ( @$available_settings ) {
        if ($params->{$setting}) {
            push @settings, qq{/$setting:"$params->{$setting}"};
        }
    }

    if ($params->{appPoolAdditionalSettings}) {
        push @settings, $params->{appPoolAdditionalSettings};
    }

    my $command = $self->get_app_cmd('set', 'apppool', qq{/apppool.name:"$name"}, @settings);
    return $command;
}

1;
