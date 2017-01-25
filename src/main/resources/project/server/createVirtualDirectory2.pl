#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/createVirtualDirectory2.pl"
# -------------------------------------------------------------------------
# File
# createVirtualDirectory2.pl
#
# Dependencies
# None
#
# Template Version
# 1.0
#
# Date
# 08/01/2011
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
my $ec_iis = EC::IIS->new;
# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

my $ec = new ElectricCommander();

# -------------------------------------------------------------------------
# Parameters
# -------------------------------------------------------------------------
my $host = ( $ec->getProperty("HostName") )->findvalue("//value");
my $virtualDirID =
  ( $ec->getProperty("VirtualDirectoryID") )->findvalue("//value");
my $virtualDirName =
  ( $ec->getProperty("VirtualDirectoryName") )->findvalue("//value");

# If GetWebSiteIDs is used prior to this, then you can use the
# property on the job <dollarsign>[/myJob/iiswebsites/<sitename>]
my $websiteid = ( $ec->getProperty("WebSiteID") )->findvalue("//value");

# This needs to be the full path to the application. We need to check if it
# starts with a slash and/or "ROOT" and prepend as needed.
my $rawappdirpath =
  ( $ec->getProperty("ApplicationDirPath") )->findvalue("//value");

# Physical absolute path to the virtual directory. i.e: c:/inetpub/wwwroot/mydir
my $physicalpath = ( $ec->getProperty("PhysicalPath") )->findvalue("//value");

# --------------------------------------------------------------------------

my $appdirpath = '';
if ( $rawappdirpath =~ /^\/root\//i ) {
    print "Path looks OK...\n";
}
else {
    if ( $rawappdirpath =~ /^\//i ) {
        print "Path starts with a slash but needs prepended /ROOT...\n";
        $appdirpath = "/ROOT";
    }
    elsif ( $rawappdirpath =~ /^root\//i ) {
        print "Path starts with ROOT but needs a prepended slash...\n";
        $appdirpath = "/ROOT";
    }
    else {
        print "Path needs prepended /ROOT/...\n";
        $appdirpath = "/ROOT";
    }
}

my $webappURL = "IIS://$host/W3SVC/$websiteid$appdirpath";
print
  "ADSI Web Application URL to create the virtual directory: $webappURL\n\n";

# Create and open a temp file for the JScript code
my ( $scriptfh, $scriptfilename ) = tempfile( DIR => '.', SUFFIX => '.js' );

# See "GetWebSiteIDs" for notes about IIS and ADSI.

# IMPORTANT: This is JScript code. If you change it to use VBScript or
# PowerShell (or whatever) you need to adjust the cscript commndline below and
# probably the SUFFIX above (although the suffix will be ignored when a /E argument
# is passed to cscript).
my $jscript = <<"EOSCRIPT";

var vdirRoot = GetObject("$webappURL");

try {
 
    var newVDir = vdirRoot.Create("IIsWebVirtualDir", "$virtualDirID");
        
    newVDir.Put ("Path", "$physicalpath");
    newVDir.Put ("AccessRead", true); 
    newVDir.Put ("AccessScript", true); 
    
    newVDir.SetInfo();
    
    WScript.Echo("Virtual directory $virtualDirID successfully created");
    
} catch(e){
 
    WScript.Echo(e.number);
    WScript.Echo(e.number & 0xFFFF);
    
}

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

my $content = `cscript /E:jscript /NoLogo $scriptfilename`;

print $content;

#evaluates if exit was successful to mark it as a success or fail the step
if ( !$? ) {

    #set any additional error or warning conditions here
    #there may be cases in which an error occurs and the exit code is 0.
    #we want to set to correct outcome for the running step
    if ( $content =~ m/Virtual directory (.+) successfully created/ ) {

        $ec->setProperty( "/myJobStep/outcome", 'success' );

    }
    else {

        $ec->setProperty( "/myJobStep/outcome", 'error' );

    }

}
else {
    $ec->setProperty( "/myJobStep/outcome", 'error' );
}

