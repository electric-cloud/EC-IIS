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
        my @nodes = $nodes->findnodes('credential/credentialName');
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

# Data that drives the create step picker registration for this plugin.	
my %startServer = (
    label       => "IIS - Start Server",
    procedure   => "StartServer",
    description => "Uses the iisreset utility to start a server.",
    category    => "Application Server"
);
my %stopServer = (
    label       => "IIS - Stop Server",
    procedure   => "StopServer",
    description => "Uses the iisreset utility to stop a server.",
    category    => "Application Server"
);
my %createAppPool = (
    label       => "IIS - Create App Pool",
    procedure   => "CreateAppPool",
    description => "Creates an IIS application pool.",
    category    => "Application Server"
);
my %createVirtualDirectory = (
    label       => "IIS - Create Virtual Directory",
    procedure   => "CreateVirtualDirectory",
    description => "Creates a new virtual directory in the specified web site.",
    category    => "Application Server"
);
my %createVirtualDirectory2 = (
    label       => "IIS - Create Virtual Directory 2",
    procedure   => "CreateVirtualDirectory2",
    description => "Uses the ADSI API to create a new virtual directory in the specified web site.",
    category    => "Application Server"
);
my %checkServerStatus = (
    label       => "IIS - Check Server Status",
    procedure   => "CheckServerStatus",
    description => "Checks the status of the specified server.",
    category    => "Application Server"
); 
my %createWebSite = ( 
    label       => "IIS - Create Web Site",
    procedure   => "CreateWebSite",
    description => "Creates a web site configuration on a local or remote computer.",
    category    => "Application Server"
);
my %createWebSite2 = (
    label       => "IIS - Create Web Site 2",
    procedure   => "CreateWebSite2",
    description => "Uses the ADSI API to create a web site on an IIS server.",
    category    => "Application Server"
);
my %startAppPool = (
    label       => "IIS - Start App Pool",
    procedure   => "StartAppPool",
    description => "Starts an IIS application pool.",
    category    => "Application Server"
);
my %createWebApplication = (
    label       => "IIS - Create Web Application",
    procedure   => "CreateWebApplication",
    description => "Creates and starts a web application in the given directory.",
    category    => "Application Server"
);
my %deleteVirtualDirectory = (
    label       => "IIS - Delete Virtual Directory",
    procedure   => "DeleteVirtualDirectory",
    description => "Deletes a virtual directory from the specified web site.",
    category    => "Application Server"
);
my %deleteWebSite = (
    label       => "IIS - Delete Web Site",
    procedure   => "DeleteWebSite",
    description => "Deletes a web site.",
    category    => "Application Server"
);
my %deployCopy = ( 
    label       => "IIS - Deploy Copy",
    procedure   => "DeployCopy",
    description => "Copies the application files to the physical directory.",
    category    => "Application Server"
);
my %getVirtualDirectories = (
    label       => "IIS - Get Virtual Directories",
    procedure   => "GetVirtualDirectories",
    description => "Returns information for all virtual directories.",
    category    => "Application Server"
);
my %getWebSiteIDs = (
    label       => "IIS - Get WebSite IDs",
    procedure   => "GetWebSiteIDs",
    description => "Fetches the numeric internal IIS identifiers of all web sites.",
    category    => "Application Server"
);
my %getWebSiteStatus = (
    label       => "IIS - Get WebSite Status",
    procedure   => "GetWebSiteStatus",
    description => "Returns the current state of the web site.",
    category    => "Application Server"
);
my %pauseWebSite = (
    label       => "IIS - Pause WebSite",
    procedure   => "PauseWebSite",
    description => "Pauses a web site.",
    category    => "Application Server"
);
my %recycleAppPool = (
    label       => "IIS - Recycle App Pool",
    procedure   => "RecycleAppPool",
    description => "Recycles an application pool.",
    category    => "Application Server"
);
my %resetServer = (
    label       => "IIS - Reset Server",
    procedure   => "ResetServer",
    description => "Uses the iisreset utility to stop a server.",
    category    => "Application Server"
);
my %resumeWebSite = (
    label       => "IIS - Resume WebSite",
    procedure   => "ResumeWebSite",
    description => "Continues server operation after it has been paused.",
    category    => "Application Server"
);
my %startWebSite = (
    label       => "IIS - Start WebSite",
    procedure   => "StartWebSite",
    description => "Starts a web site.",
    category    => "Application Server"
);
my %stopAppPool = (
    label       => "IIS - Stop App Pool",
    procedure   => "StopAppPool",
    description => "Stops an IIS application pool.",
    category    => "Application Server"
);
my %stopWebSite = (
    label       => "IIS - Stop WebSite",
    procedure   => "StopWebSite",
    description => "Stops a web site.",
    category    => "Application Server"
);
my %startIISServices = (
    label       => "IIS - Start IIS Services",
    procedure   => "StartIISServices",
    description => "Starts the necessary services to initialize the IIS server.",
    category    => "Application Server"
);
my %stopIISServices = (
    label       => "IIS - Stop IIS Services",
    procedure   => "StopIISServices",
    description => "Stops the necessary services to shut down the IIS server.",
    category    => "Application Server"
);

my %addWebSiteBinding = (
    label       => "IIS - Add Website Binding",
    procedure   => "AddWebSiteBinding",
    description => "Adds a binding to the website.",
    category    => "Application Server"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Add Website Binding");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Start Server");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Stop Server");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create Virtual Directory");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create Virtual Directory 2");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Check Server Status");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create Web Site");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create Web Site 2");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Start App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create Web Application");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Delete Virtual Directory");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Delete Web Site");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Deploy Copy");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Get Virtual Directories");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Get WebSite IDs");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Get WebSite Status");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Pause WebSite");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Recycle App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Reset Server");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Resume WebSite");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Start WebSite");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Stop App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Stop WebSite");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Start IIS Services");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Stop IIS Services");
                 
@::createStepPickerSteps = (
    \%startServer, \%stopServer,
    \%createAppPool, \%createVirtualDirectory,
    \%createVirtualDirectory2, \%checkServerStatus,
    \%createWebSite, \%createWebSite2,
    \%startAppPool, \%deleteVirtualDirectory,
    \%createWebApplication, \%deleteWebSite,
    \%deployCopy, \%getVirtualDirectories,
    \%getWebSiteIDs, \%getWebSiteStatus,
    \%pauseWebSite, \%recycleAppPool,
    \%resetServer, \%resumeWebSite,
    \%startWebSite, \%stopAppPool, 
    \%stopWebSite,
    \%startIISServices, \%stopIISServices,
    \%addWebSiteBinding,
);
