#!/usr/bin/env perl
# -------------------------------------------------------------------------
# File
# stopAppPool.pl
#
# Dependencies
# None
#
# Template Version
# 1.0
#
# Date
# 07/27/2011
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
# Name of the host to point to
my $host = ( $ec->getProperty("HostName") )->findvalue("//value");

# This needs to be the full path to the application. We need to check if it
# starts with a slash and/or "ROOT" and prepend as needed.
my $appPoolName = ( $ec->getProperty("apppoolname") )->findvalue("//value");

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
sub main() {

    $ec->abortOnError(0);

    my $webappURL = "IIS://$host/W3SVC/AppPools/$appPoolName";

    # Create and open a temp file for the JScript code
    my ( $scriptfh, $scriptfilename ) = tempfile( DIR => '.', SUFFIX => '.js' );

    # See "GetWebSiteIDs" for notes about IIS and ADSI.

# IMPORTANT: This is JScript code. If you change it to use VBScript or
# PowerShell (or whatever) you need to adjust the cscript commndline below and
# probably the SUFFIX above (although the suffix will be ignored when a /E argument
# is passed to cscript).
    my $jscript = <<"EOSCRIPT";
    // Get the virtual directory in question
    var appPool = GetObject("$webappURL");
    // Stop the app pool
    try {
        appPool.Stop();
        WScript.Echo("Application Pool $appPoolName stopped successfully");
    }
    catch(e) {
        WScript.Echo("Error: " + e.number & 0xFFFF);
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
        if ( $content =~ m/Application Pool (.+) stopped successfully/ ) {

            $ec->setProperty( "/myJobStep/outcome", 'success' );

        }
        else {

            $ec->setProperty( "/myJobStep/outcome", 'error' );

        }

    }
    else {
        $ec->setProperty( "/myJobStep/outcome", 'error' );
    }

}

main();

1;

