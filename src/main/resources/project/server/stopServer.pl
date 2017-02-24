#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/stopServer.pl"
# -------------------------------------------------------------------------
# File
#    stopServer.pl
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
use Cwd;
use File::Spec;
use Data::Dumper;

use ElectricCommander;
use ElectricCommander::PropDB;
use EC::IIS;
my $ec_iis = EC::IIS->new;
$| = 1;

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
    STOP_COMMAND   => '/stop',
    CREDENTIAL_ID  => 'credential',

    SQUOTE => q{'},
    DQUOTE => q{"},
    BSLASH => q{\\},
};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

# TODO Move into module
# $::gExecPath   = "$[execpath]";
$::gConfigName = "$[configname]";

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
    my %configuration;

    my $iisVersion = '';
    my $url        = '';
    my $user       = '';
    my $password   = '';

    if ( $::gConfigName ne '' ) {
        %configuration = getConfiguration($::gConfigName);
    }

    #inject config...
    if (%configuration) {

        if ( $configuration{'iis_url'} && $configuration{'iis_url'} ne '' ) {
            $url = $configuration{'iis_url'};
        }
        else {
            exit ERROR;
        }

        if ( $configuration{'user'} ne '' && $configuration{'password'} ne '' )
        {

            $user     = $configuration{'user'};
            $password = $configuration{'password'};

        }

    }
    else {

        exit ERROR;

    }

    #commands to be executed for version 6

    exit $ec_iis->run_reset( STOP_COMMAND );
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
