#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "[EC]/@PLUGIN_KEY@-@PLUGIN_VERSION@/getWebSiteIDs.pl"

# -------------------------------------------------------------------------
# File
#    getWebSiteIDs.pl
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
// Iterate through all Web sites looking for the given server
var w3svc = GetObject("IIS://$host/w3svc");
var e = new Enumerator(w3svc);
for (; !e.atEnd(); e.moveNext()) {
    var site = e.item();
    var indent = "";
    // Don't bother with anything but webservers
    if (site.Class != "IIsWebServer") continue;

    // Print the Name and ID
    WScript.Echo("--" + site.ServerComment + ":" + site.Name + " ");
}
EOSCRIPT

print $scriptfh $jscript;
close($scriptfh);

my @siteids = `cscript /E:jscript /NoLogo $scriptfilename`;
chomp @siteids;

print "Sites found (WebSite:ID):\n";
print @siteids;
