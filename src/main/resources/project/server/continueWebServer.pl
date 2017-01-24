#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/continueWebServer.pl"

# -------------------------------------------------------------------------
# File
#    continueWebServer.pl
#
# Dependencies
#    None
#
# Template Version
#    1.0
#
# Date
#    07/21/2011
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

my $host      = ( $ec->getProperty("HostName") )->findvalue("//value");
my $webSiteId = ( $ec->getProperty("WebSideId") )->findvalue("//value");

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
    // when it is found, it is continued.
    
    var w3svc = GetObject("IIS://$host/w3svc");
    var e = new Enumerator(w3svc);
    var siteFound = false;
    
    if(!e.atEnd()){
     
        for (; !e.atEnd() && !siteFound; e.moveNext()) {
    
            //get object from the Enum
            var site = e.item();
        
            // Don't bother with anything but webservers
            if (site.Class != "IIsWebServer") continue;
            
            // verify if the temp site obtained iterating 
            // is the one we are looking for
            if(site.Name == "$webSiteId"){
             
                // Continue a Server
                site.Continue();
            
                //Log continue statement
                WScript.Echo("Server " + site.Name + " Continued");
                
                //setting "found" flag
                siteFound = true;
                
            }
            
        }
        
        if(!siteFound){
            
            //no site match, writing to the log that the site wasn't found
            WScript.Echo("Server $webSiteId was not found");
            
        }
        
    
    }else{
     
        WScript.Echo("Host $host was not found");
        
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
        if ( $content !~ m/Server (.+) Continued/ ) {

            $ec->setProperty( "/myJobStep/outcome", 'error' );

        }
        elsif ( $content =~ m/(Server|Host) (.+) was not found/ ) {

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
