#!/usr/bin/env perl
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

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use ElectricCommander;
use Data::Dumper;
use File::Temp qw/tempfile/;

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

my $ec = new ElectricCommander();

# -------------------------------------------------------------------------
# Parameters
# -------------------------------------------------------------------------
my $host = ( $ec->getProperty("HostName") )->findvalue("//value");

my $appname = ( $ec->getProperty("ApplicationName") )->findvalue("//value");

# If GetWebSiteIDs is used prior to this, then you can use the
# property on the job <dollarsign>[/myJob/iiswebsites/<sitename>]
my $websiteid = ( $ec->getProperty("WebSiteID") )->findvalue("//value");

# This needs to be the full path to the application. We need to check if it
# starts with a slash and/or "ROOT" and prepend as needed.
my $rawappdirpath = ( $ec->getProperty("ApplicationDirPath") )->findvalue("//value");
# -------------------------------------------------------------------------



########################################################################
# main - contains the whole process to be done by the plugin
#
# Arguments:
#   none
#
# Returns:
#   none
#
########################################################################
sub main(){
 
    my $appdirpath = "";
    if ($rawappdirpath =~ /^\/root\//i) {
        print "Path looks OK...\n";
        $appdirpath = $rawappdirpath;
    }
    else {
        if ($rawappdirpath =~ /^\//i) {
            print "Path starts with a slash but needs prepended /ROOT...\n";
            $appdirpath = "/ROOT$rawappdirpath";
        }
        elsif ($rawappdirpath =~ /^root\//i) {
            print "Path starts with ROOT but needs a prepended slash...\n";
            $appdirpath = "/ROOT$rawappdirpath";
        }
        else {
         
            print "Path needs prepended /ROOT/...\n";
            
            if($rawappdirpath ne ''){
                $appdirpath = "/ROOT/$rawappdirpath";
            }else{
                $appdirpath = "/ROOT";
            }
            
        }
    }
    
    my $webappURL = "IIS://$host/W3SVC/$websiteid$appdirpath";
    print "ADSI Web Application URL: $webappURL\n\n";
    
    # Create and open a temp file for the JScript code
    my ( $scriptfh, $scriptfilename ) = tempfile( DIR => '.', SUFFIX => '.js' );
    
    # See "GetWebSiteIDs" for notes about IIS and ADSI.
    
    # IMPORTANT: This is JScript code. If you change it to use VBScript or
    # PowerShell (or whatever) you need to adjust the cscript commndline below and
    # probably the SUFFIX above (although the suffix will be ignored when a /E argument
    # is passed to cscript).
    my $jscript = <<"EOSCRIPT";
    // Get the virtual directory
    var xvdir = GetObject("$webappURL");
    // Create the app
    try {
        xvdir.AppCreate2(0);
        xvdir.Put("AppFriendlyName", "$appname");
        xvdir.SetInfo();
        
        WScript.Echo("Web Application $appname created");
    }
    catch(e) {
        WScript.Echo("Error: " + e.number + " " + e.description);
    }
    
    // Tell a bit about the VDir...
    /*
    xvdir = GetObject("$webappURL");
    WScript.Echo("Name: " + xvdir.Name);
    WScript.Echo("Type: " + xvdir.Class);
    WScript.Echo("Path: " + xvdir.Path);
    WScript.Echo("App: " + xvdir.AppFriendlyName);
    var state = xvdir.AppGetStatus2();
    var statename = stateName(state);
    WScript.Echo("State: " + state + " (" + statename + ")");
    */
    function stateName(appState) {
       switch (appState) {
          case 0:
             return "Stopped";
             break;
          case 1:
             return "Running";
             break;
          case 2:
             return "NotAnApplication";
             break;
          default:
             return "Unknown";
        }
    }
    
EOSCRIPT
    
    print $scriptfh $jscript;
    close($scriptfh);
    
    my $webappresult = `cscript /E:jscript /NoLogo $scriptfilename`;
    
    print $webappresult;
 
}

main();

1;
