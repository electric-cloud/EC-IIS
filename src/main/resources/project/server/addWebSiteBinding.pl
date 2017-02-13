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
# File
#    addWebSiteBinding.pl
#
# Dependencies
#    None
#
# Template Version
#    1.0
#
# Date
#    13/12/2011
#
# Engineer
#    Rafael Sanchez
#
# Copyright (c) 2011 Electric Cloud, Inc.
# All rights reserved
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Includes
# -------------------------------------------------------------------------
use warnings;
use strict;
use Cwd;
use File::Spec;
use Carp;

use ElectricCommander;
use ElectricCommander::PropDB;
use EC::IIS;
my $ec_iis = EC::IIS->new;

$| = 1;

print "\n\nHERE I AM\n\n";

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
use constant {
    SUCCESS => 0,
    ERROR   => 1,

    PLUGIN_NAME         => 'EC-IIS',
    WIN_IDENTIFIER      => 'MSWin32',
    DEFAULT_APPCMD_PATH => '%windir%\system32\inetsrv\appcmd',
    CREDENTIAL_ID       => 'credential',

};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

$::gEC = new ElectricCommander();
$::gEC->abortOnError(0);
$::gWebSiteName = ( $::gEC->getProperty("websitename") )->findvalue("//value");
$::gBindingProtocol =
  ( $::gEC->getProperty("bindingprotocol") )->findvalue("//value");
$::gBindingInfo =
  ( $::gEC->getProperty("bindinginformation") )->findvalue("//value");

# -------------------------------------------------------------------------
# Main functions
# -------------------------------------------------------------------------

########################################################################
# main - contains the whole process to be done by the plugin, it builds
#        the command line, sets the properties and the working directory
#
# Arguments:
#   none
#
# Returns:
#   none
#
########################################################################
sub main() {

    my @args         = ();
    my $url          = '';
    my $user         = '';
    my $pass         = '';
    my $iisVersion   = '';
    my $computerName = '';

    my $appcmdLocation = DEFAULT_APPCMD_PATH;
    my %props;

    die "Unimplemented for IIS < 7"
        unless $ec_iis->iis_version >= 7;

    Carp::cluck("I'm here");

    push( @args, $appcmdLocation . " set site" );

    if ( $::gWebSiteName && $::gWebSiteName ne '' ) {
        push( @args, '/site.name:' . $::gWebSiteName );
    }

    if (   $::gBindingProtocol
        && $::gBindingProtocol ne ''
        && $::gBindingInfo
        && $::gBindingInfo ne '' )
    {
        push( @args,
                '/+bindings.[protocol=\''
              . $::gBindingProtocol
              . '\',bindingInformation=\''
              . $::gBindingInfo
              . ':\']' );
    }

    my ($content, $ret) = $ec_iis->read_cmd(\@args);

    print $content;

    #evaluates if exit was successful to mark it as a success or fail the step
    if ( !$ret and $content !~ m/SITE object "(.+)" changed/ ) {
        $ret++;
    };

    $ec_iis->outcome_error($ret);

    exit $ret;
}

##########################################################################
# getConfiguration - get the information of the configuration given
#
# Arguments:
#   -configName: name of the configuration to retrieve
#
# Returns:
#   -configToUse: hash containing the configuration information
#
#########################################################################
sub getConfiguration($) {

    my ($configName) = @_;

    my %configToUse;

    my $proj = "$[/myProject/projectName]";
    my $pluginConfigs =
      new ElectricCommander::PropDB( $::gEC, "/projects/$proj/iis_cfgs" );

    my %configRow = $pluginConfigs->getRow($configName);

    # Check if configuration exists
    unless ( keys(%configRow) ) {
        print 'Error: Configuration doesn\'t exist';
        exit ERROR;
    }

    # Get user/password out of credential
    my $xpath = $::gEC->getFullCredential( $configRow{credential} );
    $configToUse{'user'}     = $xpath->findvalue("//userName");
    $configToUse{'password'} = $xpath->findvalue("//password");

    foreach my $c ( keys %configRow ) {

        #getting all values except the credential that was read previously
        if ( $c ne CREDENTIAL_ID ) {
            $configToUse{$c} = $configRow{$c};
        }

    }

    return %configToUse;

}

main();

1;
