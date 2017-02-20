#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "[EC]/@PLUGIN_KEY@-@PLUGIN_VERSION@/getWebSiteStatus.pl"
# -------------------------------------------------------------------------
# File
#    getWebSiteStatus.pl
#
# Dependencies
#    None
#
# Template Version
#    1.0
#
# Date
#    07/14/2011
#
# Engineer
#    Ed Cardinal
#
# Copyright (c) 2011 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

use ElectricCommander;
use Data::Dumper;
use File::Temp qw/tempfile/;

my $ec = new ElectricCommander();

# Parameters
my $host = ( $ec->getProperty("HostName") )->findvalue("//value");
print "Host: $host\n";

# If GetWebSiteIDs is used prior to this, then you can use the
# property on the job <dollarsign>[/myJob/iiswebsites/<sitename>]
my $websiteid = ( $ec->getProperty("WebSiteID") )->findvalue("//value");
print "WebsiteID: $websiteid\n\n";

# Create and open a temp file for the JScript code
my ( $scriptfh, $scriptfilename ) = tempfile( DIR => '.', SUFFIX => '.js' );

# See "GetWebSiteIDs" for notes about IIS and ADSI.

# IMPORTANT: This is JScript code. If you change it to use VBScript or
# PowerShell (or whatever) you need to adjust the cscript commndline below and
# probably the SUFFIX above (although the suffix will be ignored when a /E argument
# is passed to cscript).
my $jscript = <<"EOSCRIPT";
// Get the site in question
var website = GetObject("IIS://$host/W3SVC/$websiteid");
var stateName = stateName(website.ServerState);
WScript.Echo(website.ServerComment + ":" + website.ServerState + ":" + stateName);

function stateName(siteState) {
   // Translate the status code into English description
   switch (siteState) {
        case 1:
            return "Starting";
            break;
        case 2:
            return "Started";
            break;
        case 3:
            return "Stopping";
            break;
        case 4:
            return "Stopped";
            break;
        case 5:
            return "Pausing";
            break;
        case 6:
            return "Paused";
            break;
        case 7:
            return "Continuing";
            break;
        default:
            return "Unknown";
    }

}
EOSCRIPT

print $scriptfh $jscript;
close($scriptfh);

# There should only be one line, with a name, a numeric value, and a state name.
my $scriptresult = `cscript /E:jscript /NoLogo $scriptfilename`;
chomp $scriptresult;
my ( $sitename, $sitestate, $statename ) = split( /:/, $scriptresult );
$ec->setProperty( "/myJob/sitestatus/$sitename", $sitestate,
    { description => $statename } );
print "Web Site '$sitename': $statename";
