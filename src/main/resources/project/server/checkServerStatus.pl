#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/checkServerStatus.pl"
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

use ElectricCommander;
use ElectricCommander::PropDB;
use EC::IIS;
my $ec_iis = EC::IIS->new;
$|= 1;

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
use constant {
    SUCCESS => 0,
    ERROR   => 1,

    PLUGIN_NAME   => 'EC-IIS',
    CREDENTIAL_ID => 'credential',
    CHECK_COMMAND => '/status',

    GENERATE_REPORT        => 1,
    DO_NOT_GENERATE_REPORT => 0,

};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

$::gUseCredentials = "$[usecredentials]";
$::gConfigName     = "$[configname]";

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

    # create args array
    my @args = ();
    my %props;

    my $url  = '';
    my $port = '';
    my $user = '';
    my $pass = '';
    my %configuration;

    if ( $::gConfigName ne '' ) {
        %configuration = getConfiguration($::gConfigName);

        if ( $configuration{'iis_url'} && $configuration{'iis_url'} ne '' ) {
            $url = $configuration{'iis_url'};
        }
        else {
            print 'Could not get URL from configuration ' . $::gConfigName;
            exit ERROR;
        }

        if ( $configuration{'iis_port'} && $configuration{'iis_port'} ne '' ) {
            $port = $configuration{'iis_port'};
        }
        if ($::gUseCredentials) {
            if ( $configuration{'user'} && $configuration{'user'} ne '' ) {
                $user = $configuration{'user'};
            }
            else {
#                print 'Could not get user from configuration '. $::gConfigName;
#                exit ERROR;
            }
        }
        if ( $configuration{'password'} && $configuration{'password'} ne '' ) {
            $pass = $configuration{'password'};
        }
        else {
#            print 'Could not get password from configuration '. $::gConfigName;
#            exit ERROR;
        }

    }

    #commands to be executed for version 6
    my $ret = $ec_iis->run_reset( CHECK_COMMAND );
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
