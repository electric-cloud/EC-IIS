#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/createWebSite2.pl"

# -------------------------------------------------------------------------
# File
#    createWebSite2.pl
#
# Dependencies
#    None
#
# Template Version
#    1.0
#
# Date
#    08/18/2011
#
# Engineer
#    Alonso Blanco
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
# Constants
# -------------------------------------------------------------------------
use constant {
    SUCCESS => 0,
    ERROR   => 1,

    PLUGIN_NAME    => 'EC-IIS',
    WIN_IDENTIFIER => 'MSWin32',
    IIS_VERSION_6  => 'iis6',
    IIS_VERSION_7  => 'iis7',
    CREDENTIAL_ID  => 'credential',
};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

my $ec = new ElectricCommander();

my $host          = ( $ec->getProperty("HostName") )->findvalue("//value");
my $physicalPath  = ( $ec->getProperty("PhysicalPath") )->findvalue("//value");
my $serverComment = ( $ec->getProperty("ServerComment") )->findvalue("//value");
my $bindings      = ( $ec->getProperty("Bindings") )->findvalue("//value");
my $serverID      = ( $ec->getProperty("ServerID") )->findvalue("//value");
my $generateRandomServerID =
  ( $ec->getProperty("GenerateRandomID") )->findvalue("//value");

########################################################################
# main - contains the whole process to be done by the perl file
#
# Arguments:
#   none
#
# Returns:
#   none
#
########################################################################
sub main() {

    # Create and open a temp file for the JScript code
    my ( $scriptfh, $scriptfilename ) = tempfile( DIR => '.', SUFFIX => '.js' );

# Some notes about IIS and ADSI terminology:
# In the IIS manager GUI, entities under the "Web Sites" heading are in
# the ADSI "IIsWebServer" class. The ServerComment attribute of
# that IISWebServer object is what is shown as the name of the entry in the GUI.
# The Name attribute is actually an ID number necessary to identify the site in
# order to create an application in a virtual directory (objects of the ADSI
# class "IIsWebVirtualDir") within the site. In the GUI, applications are
# distinguished from regular vdirs by the gear icon instead of a folder icon.

   # The ID of a Web Site can be found in the manager GUI (sort of). Open the
   # Properties dialog of a web site and click on the "Properties" button in the
   # Logging section at the bottom of the dialog. Look at the name of the log
   # file at the bottom of that Logging Properties dialog: the site ID number
   # follows the letters "W3SVC". Ouch.

# IMPORTANT: This is JScript code. If you change it to use VBScript or
# PowerShell (or whatever) you need to adjust the cscript commndline below and
# probably the SUFFIX above (although the suffix will be ignored when a /E argument
# is passed to cscript).
    my $jscript = <<"EOSCRIPT";
    // Iterate through all Web sites looking for the given server and then
    // when it is found, it is paused.
    
    var w3svc = GetObject("IIS://$host/w3svc");
    var myNewSiteID;
    var bindings = new Array();
    bindings[0] = "$bindings";
    
    var generateRandomKey = "$generateRandomServerID";

    try{
       
       if(generateRandomKey == "1"){
           
           //random key
           myNewSiteID = w3svc.CreateNewSite(
                 "$serverComment", 
                  bindings, 
                 "$physicalPath");
          
           WScript.Echo("using random ID");
       
       }else{
        
           //create with supplied server ID
           myNewSiteID = w3svc.CreateNewSite(
                 "$serverComment", 
                 bindings, 
                 "$physicalPath", 
                 "$serverID");
                 
           WScript.Echo("using supplied ID");
       }
       
        WScript.Echo("WebSite $serverComment created successfully with ID " + 
            myNewSiteID);
       
    }catch(e){
     
        WScript.Echo("Error: " + e.number + " " + e.description);
    }
    
EOSCRIPT

    print $scriptfh $jscript;
    close($scriptfh);

    my $content = `cscript /E:jscript /NoLogo $scriptfilename`;

    print $content;

    #evaluates if exit was successful to mark it as a success or fail the step
    if ( $? == SUCCESS ) {

        #set any additional error or warning conditions here
        #there may be cases in which an error occurs and the exit code is 0.
        #we want to set to correct outcome for the running step
        if ( $content !~ m/WebSite (.*) created successfully with ID (.+)/ ) {

            $ec->setProperty( "/myJobStep/outcome", 'error' );

        }
    }
    else {
        $ec->setProperty( "/myJobStep/outcome", 'error' );
    }

    #foreach my $siteinfo (@siteids) {
    #    ($sitename,$siteid) = split(/:/, $siteinfo);
    #    print "$sitename ($siteid)\n";
    #    $ec->setProperty("/myJob/iiswebsites/$sitename", $siteid);
    #}

}

main();

1;
