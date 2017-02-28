#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "[EC]/@PLUGIN_KEY@-@PLUGIN_VERSION@/checkServerStatus.pl"
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
#    checkServerStatus.pl
#
# Dependencies
#    None
#
# Template Version
#    1.0
#
# Date
#    11/05/2010
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
use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Request;
$| = 1;

use ElectricCommander;
use ElectricCommander::PropDB;
use EC::IIS;
# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
use constant {
    SUCCESS => 0,
    ERROR   => 1,

    PLUGIN_NAME   => 'EC-IIS',
    CREDENTIAL_ID => 'credential',

    GENERATE_REPORT        => 1,
    DO_NOT_GENERATE_REPORT => 0,

};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

my $iis = EC::IIS->new;
my $ec  = ElectricCommander->new;
my $gUseCredentials = $ec->getProperty("usecredentials")->findvalue("//value");
my $gConfigName     = $ec->getProperty("configname")->findvalue("//value");
my $gUrl            = $ec->getProperty("checkUrl")->findvalue("//value");
my $gExpectStatus   = $ec->getProperty("expectStatus")->findvalue("//value");
my $gUnavailable    = $ec->getProperty("unavailable")->findvalue("//value");
my $gTimeout        = $ec->getProperty("timeout")->findvalue("//value");
my $gRetries        = $ec->getProperty("retries")->findvalue("//value");
# my $gContentRex     = $ec->getProperty("contentRex")->findvalue("//value");

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
sub main {

    # create args array
    my %props;

    my $url  = '';
    my $port = '';
    my $user = '';
    my $pass = '';
    my %configuration;

    if ( $gConfigName ne '' ) {
        %configuration = getConfiguration($gConfigName);

        if ( $configuration{'iis_url'} && $configuration{'iis_url'} ne '' ) {
            $url = $configuration{'iis_url'};
        }
        else {
            print 'Could not get URL from configuration ' . $gConfigName;
            exit ERROR;
        }

        if ( $configuration{'iis_port'} && $configuration{'iis_port'} ne '' ) {
            $port = $configuration{'iis_port'};
        }
        if ($gUseCredentials) {
            if ( $configuration{'user'} && $configuration{'user'} ne '' ) {
                $user = $configuration{'user'};
            }
            else {
                #print 'Could not get user from configuration '. $gConfigName;
                #exit ERROR;
            }
        }
        if ( $configuration{'password'} && $configuration{'password'} ne '' ) {
            $pass = $configuration{'password'};
        }
        else {
            #print 'Could not get password from configuration '. $gConfigName;
            #exit ERROR;
        }

    }

    #inject port
    if ( $port ne '' ) {
        $url =~ s/(\/*)$/:$port/;
    }

    my %opt = (
        url => $gUrl || $url,
        status => $gExpectStatus,
        unavailable => $gUnavailable,
        timeout => $gTimeout,
        tries => $gRetries,
        # content => $gContentRex 
    );

    if ($gUseCredentials) {
        $opt{user} = $user;
        $opt{pass} = $pass;
    }



    my $error = $iis->check_http_status( %opt );

    # Check the outcome of the response
    if ( !$error ) {
        print "URL successful: $url\n";
    }
    else {
        print "Error: $error\n";
    }
    $props{'checkServerStatusLine'} = $url;
    $props{'checkServerStatusError'} = $error;
    $iis->setProperties( \%props );
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
sub getConfiguration {

    my ($configName) = @_;

    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);

    my %configToUse;

    my $proj = "$[/myProject/projectName]";
    my $pluginConfigs =
      new ElectricCommander::PropDB( $ec, "/projects/$proj/iis_cfgs" );

    my %configRow = $pluginConfigs->getRow($configName);

    # Check if configuration exists
    unless ( keys(%configRow) ) {
        print "Error: Configuration doesn\'t exist\n";
        exit ERROR;
    }

    # Get user/password out of credential
    my $xpath = $ec->getFullCredential( $configRow{credential} );
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
