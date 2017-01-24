#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/disableWebApplication.pl"
# -------------------------------------------------------------------------
# File
# disableWebApplication.pl
#
# Dependencies
# None
#
# Template Version
# 1.0
#
# Date
# 07/26/2011
#
# Engineer
# Alonso Blanco
#
# Copyright (c) 2011 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use strict;
use warnings;
use Data::Dumper;
use File::Temp qw/tempfile/;

use ElectricCommander;
use EC::IIS;

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

my $ec = new ElectricCommander();

# -------------------------------------------------------------------------
# Parameters
# -------------------------------------------------------------------------
my $host    = ( $ec->getProperty("HostName") )->findvalue("//value");
my $appname = ( $ec->getProperty("ApplicationName") )->findvalue("//value");

# If GetWebSiteIDs is used prior to this, then you can use the
# property on the job <dollarsign>[/myJob/iiswebsites/<sitename>]
my $websiteid = ( $ec->getProperty("WebSiteID") )->findvalue("//value");

# This needs to be the full path to the application. We need to check if it
# starts with a slash and/or "ROOT" and prepend as needed.
my $rawappdirpath =
  ( $ec->getProperty("ApplicationDirPath") )->findvalue("//value");
my $disableRecursive =
  ( $ec->getProperty("disablerecursive") )->findvalue("//value");

# --------------------------------------------------------------------------

my $appdirpath = "";
if ( $rawappdirpath =~ /^\/root\//i ) {
    print "Path looks OK...\n";
    $appdirpath = $rawappdirpath;
}
else {
    if ( $rawappdirpath =~ /^\//i ) {
        print "Path starts with a slash but needs prepended /ROOT...\n";
        $appdirpath = "/ROOT$rawappdirpath";
    }
    elsif ( $rawappdirpath =~ /^root\//i ) {
        print "Path starts with ROOT but needs a prepended slash...\n";
        $appdirpath = "/ROOT$rawappdirpath";
    }
    else {
        print "Path needs prepended /ROOT/...\n";
        $appdirpath = "/ROOT/$rawappdirpath";
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
// Get the virtual directory in question
var xvdir = GetObject("$webappURL");
// Create the app
try {
 
    if("$disableRecursive" == "1"){
        WScript.Echo("Disabling application recursively...");
        xvdir.AppDisableRecursive();
    }else{
        WScript.Echo("Disabling application...");
        xvdir.AppDisable(); 
    }
    
    xvdir.Put("AppFriendlyName", "$appname");
    xvdir.SetInfo();
    
    WScript.Echo("Application disabled");
    
}
catch(e) {
    WScript.Echo("Error: " + e.number & 0xFFFF);
}

// Tell a bit about the VDir...
xvdir = GetObject("$webappURL");

var state = xvdir.AppGetStatus2();
var statename = stateName(state);

WScript.Echo("State: " + state + " (" + statename + ")");

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

my @webappresult = `cscript /E:jscript /NoLogo $scriptfilename`;

print "Disable Web Application Results:\n";
print @webappresult;
