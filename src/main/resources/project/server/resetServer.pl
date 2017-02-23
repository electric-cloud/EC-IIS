#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "[EC]/@PLUGIN_KEY@-@PLUGIN_VERSION@/resetServer.pl"
# -------------------------------------------------------------------------
# File
#    resetServer.pl
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
use ElectricCommander;
use warnings;
use strict;
use Cwd;
use File::Spec;
use diagnostics;
use Data::Dumper;
use ElectricCommander::PropDB;
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

    CREDENTIAL_ID => 'credential',
};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

$::gExecPath   = "$[execpath]";
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
    # TODO Fail LOUDLY
    if (%configuration) {

        if ( $configuration{'iis_url'} && $configuration{'iis_url'} ne '' ) {
            $url = $configuration{'iis_url'};
        }
        else {
            die "Failed to locate URL in IIS configuration '$::gConfigName'";
        }

        if ( $configuration{'user'} ne '' && $configuration{'password'} ne '' )
        {

            $user     = $configuration{'user'};
            $password = $configuration{'password'};

        }

    }
    else {
        die "Failed to locate IIS configuration '$::gConfigName'";
    }

    #commands to be executed for version 6
    push( @args, $::gExecPath );

    #generate command line
    my $cmdLine = createCommandLine( \@args );

    if ( $cmdLine && $cmdLine ne '' ) {

        #execute command line
        system($cmdLine);

        #show command line
        print "Command Line: $cmdLine\n";

        #add masked command line to properties object
        $props{'cmdLine'} = $cmdLine;

        #set prop's hash to EC properties
        setProperties( \%props );

    }
    else {
        die "Error: could not generate command line";
    }

}

########################################################################
# createCommandLine - creates the command line for the invocation
# of the program to be executed.
#
# Arguments:
#   -arr: array containing the command name (must be the first element)
#         and the arguments entered by the user in the UI
#
# Returns:
#   -the command line to be executed by the plugin
#
########################################################################
sub createCommandLine($) {

    my ($arr) = @_;

    my $commandName = @$arr[0];

    my $command = $commandName;

    shift(@$arr);

    foreach my $elem (@$arr) {
        $command .= " $elem";
    }

    return $command;

}

########################################################################
# setProperties - set a group of properties into the Electric Commander
#
# Arguments:
#   -propHash: hash containing the ID and the value of the properties
#              to be written into the Electric Commander
#
# Returns:
#   none
#
########################################################################
sub setProperties($) {

    my ($propHash) = @_;

    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);

    foreach my $key ( keys %$propHash ) {
        my $val = $propHash->{$key};
        $ec->setProperty( "/myCall/$key", $val );
    }
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
        die "Failed to locate configRow in config '$configName'";
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
