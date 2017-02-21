#
#  Copyright 2015 Electric Cloud, Inc.
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

my %checkServerStatus = (
    label       => "IIS - Check Server Status",
    procedure   => "CheckServerStatus",
    description => "Checks the status of the specified server.",
    category    => "Application Server"
);
my %addWebSiteBinding = (
    label       => "IIS - Add Website Binding",
    procedure   => "AddWebSiteBinding",
    description => "Adds a binding to the website.",
    category    => "Application Server"
);
my %assignAppToAppPool = (
    label       => "IIS - Assign App To App Pool",
    procedure   => "AssignAppToAppPool",
    description => "Assigns an application to an application pool.",
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
    description => "Creates a new virtual directory in the specified website.",
    category    => "Application Server"
);
my %createWebApplication = (
    label       => "IIS - Create Web Application",
    procedure   => "CreateWebApplication",
    description => "Creates and starts an in-process web application in the given directory.",
    category    => "Application Server"
);
my %createWebSite = (
    label       => "IIS - Create Website",
    procedure   => "CreateWebSite",
    description => "Creates a website configuration on a local or remote computer.",
    category    => "Application Server"
);
my %deleteAppPool = (
    label       => "IIS - Delete App Pool",
    procedure   => "DeleteAppPool",
    description => "Deletes an application pool.",
    category    => "Application Server"
);
my %deleteVirtualDirectory = (
    label       => "IIS - Delete Virtual Directory",
    procedure   => "DeleteVirtualDirectory",
    description => "Deletes a virtual directory from the specified website.",
    category    => "Application Server"
);
my %deleteWebApplication = (
    label       => "IIS - Delete Web Application",
    procedure   => "DeleteWebApplication",
    description => "Deletes a web application.",
    category    => "Application Server"
);
my %deleteWebSite = (
    label       => "IIS - Delete Website",
    procedure   => "DeleteWebSite",
    description => "Deletes a website.",
    category    => "Application Server"
);
my %deployCopy = (
    label       => "IIS - Deploy Copy",
    procedure   => "DeployCopy",
    description => "Copies the application files recursively to the website application's physical directory.",
    category    => "Application Server"
);
my %listSiteApps = (
    label       => "IIS - List Site Apps",
    procedure   => "ListSiteApps",
    description => "List the apps of a Website.",
    category    => "Application Server"
);
my %listSites = (
    label       => "IIS - List Sites",
    procedure   => "ListSites",
    description => "List the sites on a web server.",
    category    => "Application Server"
);
my %startAppPool = (
    label       => "IIS - Start App Pool",
    procedure   => "StartAppPool",
    description => "Starts an IIS application pool.",
    category    => "Application Server"
);
my %startWebSite = (
    label       => "IIS - Start Website",
    procedure   => "StartWebSite",
    description => "Starts a website.",
    category    => "Application Server"
);
my %stopAppPool = (
    label       => "IIS - Stop App Pool",
    procedure   => "StopAppPool",
    description => "Stops an IIS application pool.",
    category    => "Application Server"
);	
my %stopWebSite = (
    label       => "IIS - Stop Website",
    procedure   => "StopWebSite",
    description => "Stops an IIS Website.",
    category    => "Application Server"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Check Server Status");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Add Website Binding");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Assign App To App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create Virtual Directory");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create Web Application");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Create Website");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Delete App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Delete Virtual Directory");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Delete Web Application");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Delete Website");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Deploy Copy");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - List Site Apps");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - List Sites");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Start App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Start Website");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Stop App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS - Stop Website");

@::createStepPickerSteps = (\%checkServerStatus, \%addWebSiteBinding,
                            \%assignAppToAppPool, \%createAppPool,
                            \%createVirtualDirectory, \%createWebApplication,
                            \%createWebSite, \%deleteAppPool,
                            \%deleteVirtualDirectory, \%deleteWebApplication,
                            \%deleteWebSite, \%deployCopy,
                            \%listSiteApps, \%listSites,
                            \%startAppPool, \%startWebSite,
                            \%stopAppPool, \%stopWebSite);
