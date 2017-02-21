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
    label       => "IIS7 - Check Server Status",
    procedure   => "CheckServerStatus",
    description => "Checks the status of the specified server.",
    category    => "Application Server"
);
my %addWebSiteBinding = (
    label       => "IIS7 - Add Website Binding",
    procedure   => "AddWebSiteBinding",
    description => "Adds a binding to the website.",
    category    => "Application Server"
);
my %assignAppToAppPool = (
    label       => "IIS7 - Assign App To App Pool",
    procedure   => "AssignAppToAppPool",
    description => "Assigns an application to an application pool.",
    category    => "Application Server"
);
my %createAppPool = (
    label       => "IIS7 - Create App Pool",
    procedure   => "CreateAppPool",
    description => "Creates an IIS application pool.",
    category    => "Application Server"
);
my %createVirtualDirectory = (
    label       => "IIS7 - Create Virtual Directory",
    procedure   => "CreateVirtualDirectory",
    description => "Creates a new virtual directory in the specified website.",
    category    => "Application Server"
);
my %createWebApplication = (
    label       => "IIS7 - Create Web Application",
    procedure   => "CreateWebApplication",
    description => "Creates and starts an in-process web application in the given directory.",
    category    => "Application Server"
);
my %createWebSite = (
    label       => "IIS7 - Create Website",
    procedure   => "CreateWebSite",
    description => "Creates a website configuration on a local or remote computer.",
    category    => "Application Server"
);
my %deleteAppPool = (
    label       => "IIS7 - Delete App Pool",
    procedure   => "DeleteAppPool",
    description => "Deletes an application pool.",
    category    => "Application Server"
);
my %deleteVirtualDirectory = (
    label       => "IIS7 - Delete Virtual Directory",
    procedure   => "DeleteVirtualDirectory",
    description => "Deletes a virtual directory from the specified website.",
    category    => "Application Server"
);
my %deleteWebApplication = (
    label       => "IIS7 - Delete Web Application",
    procedure   => "DeleteWebApplication",
    description => "Deletes a web application.",
    category    => "Application Server"
);
my %deleteWebSite = (
    label       => "IIS7 - Delete Website",
    procedure   => "DeleteWebSite",
    description => "Deletes a website.",
    category    => "Application Server"
);
my %deployCopy = (
    label       => "IIS7 - Deploy Copy",
    procedure   => "DeployCopy",
    description => "Copies the application files recursively to the website application's physical directory.",
    category    => "Application Server"
);
my %listSiteApps = (
    label       => "IIS7 - List Site Apps",
    procedure   => "ListSiteApps",
    description => "List the apps of a Website.",
    category    => "Application Server"
);
my %listSites = (
    label       => "IIS7 - List Sites",
    procedure   => "ListSites",
    description => "List the sites on a web server.",
    category    => "Application Server"
);
my %startAppPool = (
    label       => "IIS7 - Start App Pool",
    procedure   => "StartAppPool",
    description => "Starts an IIS application pool.",
    category    => "Application Server"
);
my %startWebSite = (
    label       => "IIS7 - Start Website",
    procedure   => "StartWebSite",
    description => "Starts a website.",
    category    => "Application Server"
);
my %stopAppPool = (
    label       => "IIS7 - Stop App Pool",
    procedure   => "StopAppPool",
    description => "Stops an IIS application pool.",
    category    => "Application Server"
);	
my %stopWebSite = (
    label       => "IIS7 - Stop Website",
    procedure   => "StopWebSite",
    description => "Stops an IIS Website.",
    category    => "Application Server"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Check Server Status");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Add Website Binding");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Assign App To App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Create App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Create Virtual Directory");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Create Web Application");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Create Website");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Delete App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Delete Virtual Directory");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Delete Web Application");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Delete Website");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Deploy Copy");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - List Site Apps");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - List Sites");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Start App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Start Website");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Stop App Pool");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/IIS7 - Stop Website");

@::createStepPickerSteps = (\%checkServerStatus, \%addWebSiteBinding,
                            \%assignAppToAppPool, \%createAppPool,
                            \%createVirtualDirectory, \%createWebApplication,
                            \%createWebSite, \%deleteAppPool,
                            \%deleteVirtualDirectory, \%deleteWebApplication,
                            \%deleteWebSite, \%deployCopy,
                            \%listSiteApps, \%listSites,
                            \%startAppPool, \%startWebSite,
                            \%stopAppPool, \%stopWebSite);
