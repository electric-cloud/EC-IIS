if ($promoteAction eq "promote") {
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - StartServer",
                            {
                               description => "Uses the iisreset utility to start a server.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/StartServer]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - StopServer",
                            {
                               description => "Uses the iisreset utility to stop a server.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/StopServer]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - CreateAppPool",
                            {
                               description => "This procedure creates an IIS application pool.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/CreateAppPool]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - CreateVirtualDirectory",
                            {
                               description => "This procedure creates a new virtual directory in the specified web site.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/CreateVirtualDirectory]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - CreateWebSite",
                            {
                               description => "This procedure creates a web site configuration on a local or remote computer.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/CreateWebSite]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - CreateVirtualDirectory2",
                            {
                               description => "Specify the path within the web site to the application directory (not the physical path).",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/CreateVirtualDirectory2]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - CreateWebSite2",
                            {
                               description => "This procedure uses the ADSI API to create a web site on an IIS server.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/CreateWebSite2]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - StartAppPool",
                            {
                               description => "This procedure starts an IIS application pool.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/StartAppPool]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - CheckServerStatus",
                            {
                               description => "This procedure checks the status of the specified server.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/CheckServerStatus]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - CreateWebApplication",
                            {
                               description => "This procedure creates and starts an in-process web application in the given directory.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/CreateWebApplication]'
                            }
                           
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - DeleteVirtualDirectory",
                            {
                               description => "This procedure deletes a virtual directory from the specified web site.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/DeleteVirtualDirectory]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - DeleteWebSite",
                            {
                               description => "This procedure deletes a web site.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/DeleteWebSite]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - DeployCopy",
                            {
                               description => "This procedure copies the application files recursively to the web site application's physical directory.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/DeployCopy]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - GetVirtualDirectories",
                            {
                               description => "This procedure returns basic information for all virtual directories defined for the web site (recursively). This procedure is primarily for gathering information rather than performing specific actions.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/GetVirtualDirectories]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - GetWebSiteIDs",
                            {
                               description => "This procedure fetches the numeric internal IIS identifiers of all web sites found on the host server. These IDs are necessary to access internal web site properties in order to perform certain control operations.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/GetWebSiteIDs]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - GetWebSiteStatus",
                            {
                               description => "This procedure returns the current state of the web site. The state is also saved in a Job Property under the sitestatus property sheet, with the web site name as the property name and the numeric status code as the value. Possible status values: 1 (starting), 2 (started), 3 (stopping), 4 (stopped), 5 (pausing), 6 (paused), or 7 (continuing).",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/GetWebSiteStatus]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - PauseWebSite",
                            {
                               description => "This procedure pauses a web site. This is similar to stopping, except pausing allows existing processes to continue to their conclusion.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/PauseWebSite]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - RecycleAppPool",
                            {
                               description => "This procedure recycles an application pool. When recycling occurs, the worker process currently serving the application pool terminates and the WWW service restarts a new worker process to replace it.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/RecycleAppPool]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - ResetServer",
                            {
                               description => "This procedure uses the iisreset utility to reset a server.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/ResetServer]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - ResumeWebSite",
                            {
                               description => "This procedure continues server operation after it has been paused.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/ResumeWebSite]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - StartWebSite",
                            {
                               description => "This procedure starts a web site.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/StartWebSite]'
                            }
                           );
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - StopAppPool",
                            {
                               description => "This procedure stops an IIS application pool.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/StopAppPool]'
                            }
                           );                           
	$batch->setProperty(
                            "/server/ec_customEditors/pluginStep/IIS - StopWebSite",
                            {
                               description => "This procedure stops a web site.",
                               value       => '$[/plugins/@PLUGIN_KEY@-@PLUGIN_VERSION@/project/ui_forms/StopWebSite]'
                            }
                           );
} elsif ($promoteAction eq "demote") {
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - StartServer");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - StopServer");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - CreateAppPool");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - CreateVirtualDirectory");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - CreateVirtualDirectory2");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - CheckServerStatus");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - CreateWebSite");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - CreateWebSite2");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - StartAppPool");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - CreateWebApplication");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - DeleteVirtualDirectory");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - DeleteWebSite");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - DeployCopy");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - GetVirtualDirectories");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - GetWebSiteIDs");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - GetWebSiteStatus");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - PauseWebSite");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - RecycleAppPool");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - ResetServer");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - ResumeWebSite");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - StartWebSite");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - StopAppPool");
	$batch->deleteProperty("/server/ec_customEditors/pluginStep/IIS - StopWebSite");
}

if ($upgradeAction eq "upgrade") {
    my $query = $commander->newBatch();
    my $newcfg = $query->getProperty(
        "/plugins/$pluginName/project/iis_cfgs");
    my $oldcfgs = $query->getProperty(
        "/plugins/$otherPluginName/project/iis_cfgs");
	my $creds = $query->getCredentials(
        "\$[/plugins/$otherPluginName]");

	local $self->{abortOnError} = 0;
    $query->submit();

    # if new plugin does not already have cfgs
    if ($query->findvalue($newcfg,"code") eq "NoSuchProperty") {
        # if old cfg has some cfgs to copy
        if ($query->findvalue($oldcfgs,"code") ne "NoSuchProperty") {
            $batch->clone({
                path => "/plugins/$otherPluginName/project/iis_cfgs",
                cloneName => "/plugins/$pluginName/project/iis_cfgs"
            });
        }
    }
    
    # Copy configuration credentials and attach them to the appropriate steps
    my $nodes = $query->find($creds);
    if ($nodes) {
        my @nodes = $query->{xpath}->findnodes("credential/credentialName", $nodes);
        for (@nodes) {
            my $cred = $_->string_value;

            # Clone the credential
            $batch->clone({
                path => "/plugins/$otherPluginName/project/credentials/$cred",
                cloneName => "/plugins/$pluginName/project/credentials/$cred"
            });

            # Make sure the credential has an ACL entry for the new project principal
            my $xpath = $commander->getAclEntry("user", "project: $pluginName", {
                projectName => $otherPluginName,
                credentialName => $cred
            });
            if ($xpath->findvalue("//code") eq "NoSuchAclEntry") {
                $batch->deleteAclEntry("user", "project: $otherPluginName", {
                    projectName => $pluginName,
                    credentialName => $cred
                });
                $batch->createAclEntry("user", "project: $pluginName", {
                    projectName => $pluginName,
                    credentialName => $cred,
                    readPrivilege => 'allow',
                    modifyPrivilege => 'allow',
                    executePrivilege => 'allow',
                    changePermissionsPrivilege => 'allow'
                });
            }


        }
    }
}
