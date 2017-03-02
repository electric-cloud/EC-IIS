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


sub after_init_hook {
    my ($self, %params) = @_;
    $self->debug_level(1);
}


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

sub recycle_app_pool_cmd {
    my ($self, $params) = @_;

    my $name = $params->{applicationPool};
    unless($name) {
        $self->bail_out("No application pool name is provided");
    }
    return $self->get_app_cmd('recycle', 'apppool', qq{/apppool.name:"$name"});
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

sub check_vdir_exists {
    my ($self, $name) = @_;

    my $command = $self->get_app_cmd('list', 'vdirs', qq{"$name"});
    my $result = $self->run_command($command);
    $self->logger->debug($command);
    $self->logger->debug($result);
    return $result->{stdout} && $result->{stdout} =~ m/VDIR "$name"/;
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


sub check_application_exists {
    my ($self, $appname) =  @_;

    my $command = $self->get_app_cmd('list', 'apps', qq{/app.name:"$appname"});
    $self->logger->debug($command);
    my $result = $self->run_command($command);
    $self->logger->debug($result);
    return $result->{stdout} && $result->{stdout} =~ m/APP "$appname"/;
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


sub seconds_to_time_span {
    my ($self, $seconds) = @_;

    my ($hours, $minutes, $seconds_left);

    ($hours, $seconds_left) = div_mod($seconds, 60 * 60);
    ($minutes, $seconds_left) = div_mod($seconds_left, 60);

    my $span = sprintf('%02d:%02d:%02d', $hours, $minutes, $seconds_left);
    return $span;
}


sub div_mod {
    my ($a, $b) = @_;
    return (int($a/$b), $a % $b);
}

sub check_site_exists {
    my ($self, $site) = @_;

    my $command = $self->get_app_cmd('list', 'sites', qq{/name:"$site"});
    my $result = $self->run_command($command);
    $self->logger->debug($result);
    return $result->{stdout} ? 1 : 0;
}

sub create_site_cmd {
    my ($self, $params) = @_;

    my @command_parts = qw/add site/;
    if ($params->{websiteName}) {
        push @command_parts, qq{/site.name:"$params->{websiteName}"};
    }
    else {
        return $self->bail_out("Cannot create a site without site name");
    }
    if ($params->{bindings}) {
        push @command_parts, qq{/bindings:"$params->{bindings}"};
    }

    if ($params->{physicalPath}) {
        push @command_parts, qq{/physicalPath:"$params->{physicalPath}"};
    }
    if ($params->{websiteId}) {
        push @command_parts, qq{/id:"$params->{websiteId}"};
    }
    return $self->get_app_cmd(@command_parts);
}

sub update_site_cmd {
    my ($self, $params) = @_;

    my @command_parts = qw/set site/;
    if ($params->{websiteName}) {
        push @command_parts, qq{"$params->{websiteName}"};
        push @command_parts, qq{/name:"$params->{websiteName}"};
    }
    else {
        return $self->bail_out("Cannot create a site without site name");
    }
    if ($params->{bindings}) {
        push @command_parts, qq{/bindings:"$params->{bindings}"};
    }
    if ($params->{websiteId}) {
        push @command_parts, qq{/id:$params->{websiteId}};
    }
    return $self->get_app_cmd(@command_parts);
}

sub update_vdir_cmd {
    my ($self, $params) = @_;

    my $name = $params->{vdirName};
    my @command_parts = qw/set vdir/;
    unless($name) {
        $self->bail_out("No virtual directory name is provided");
    }

    push @command_parts, qq{"$name"};
    push @command_parts, qq{/vdir.name:"$name"};
    if ($params->{physicalPath}) {
        push @command_parts, qq{/physicalPath:"$params->{physicalPath}"};
    }
    return $self->get_app_cmd(@command_parts);
}

sub create_vdir_cmd {
    my ($self, $params) = @_;

    my $cmd = $self->get_app_cmd('add', 'vdir',
        qq{/app.name:"$params->{applicationName}"},
        qq{/path:"$params->{path}"},
        qq{/physicalPath:"$params->{physicalPath}"}
    );
    return $cmd;
}

sub delete_app_pool_cmd {
    my ($self, $params) = @_;

    my $name = $params->{applicationPool};
    unless($name) {
        return $self->bail_out("No application pool name is provided");
    }

    return $self->get_app_cmd('delete', 'apppool', qq{/apppool.name:"$name"});
}


sub delete_vdir_cmd {
    my ($self, $params) = @_;

    my $name = $params->{vdirName};
    unless($name) {
        return $self->bail_out("No virtual directory name is provided");
    }

    return $self->get_app_cmd('delete', 'vdir', qq{/vdir.name:"$name"});
}


sub delete_site_cmd {
    my ($self, $params) = @_;

    my $name = $params->{websiteName};
    unless($name) {
        $self->bail_out("No website name was specified");
    }
    return $self->get_app_cmd('delete', 'site', qq{/site.name:"$name"});
}

1;
