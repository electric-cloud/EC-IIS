#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/createWebSite.pl"
# -------------------------------------------------------------------------
# File
#    createWebSite.pl
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
use diagnostics;

use ElectricCommander;
use ElectricCommander::PropDB;
use EC::IIS qw(trim);
my $ec_iis = EC::IIS->new;
$| = 1;

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
use constant {
    SUCCESS => 0,
    ERROR   => 1,

    PLUGIN_NAME                         => 'EC-IIS',
    WIN_IDENTIFIER                      => 'MSWin32',
    IIS_VERSION_6                       => 'iis6',
    IIS_VERSION_7                       => 'iis7',
    DEFAULT_CREATE_COMMAND_OPTION_IIS_6 => '/create',
    DEFAULT_CREATE_COMMAND_OPTION_IIS_7 => 'add site',
    CREDENTIAL_ID                       => 'credential',

    SQUOTE => q{'},
    DQUOTE => q{"},
    BSLASH => q{\\},
};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

my $gWebsite              = trim(q($[sitename]));
my $gExecPath             = trim(q($[execpath]));
my $gConfigName           = trim(q($[configname]));
my $gAbsolutePhysicalPath = trim(q($[appabsolutepath]));
my $gHostHeader           = trim(q($[hostheader]));
my $gStartSite            = trim(q($[startapp]));
my $gBindings             = 'http/*:1337:';

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

    my $port      = '';
    my $ipAddress = '';

    my %configuration;
    my %props;

    #get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);

    if ( $gConfigName ne '' ) {

        %configuration = getConfiguration($gConfigName);

        if ( $configuration{'iis_url'} && $configuration{'iis_url'} ne '' ) {

            $url = $configuration{'iis_url'};

          #evaluates if the received url has the protocol://host:port/dir format
          #            if($url =~ m/(.+):\/\/(.+)(:*)(\d*)(\/*.*|\/*)/){
          #
          #                $ipAddress = $2;
          #                $port = $4;
          #            }

        }
        else {
            print 'Error: Could not get URL from configuration '
              . $gConfigName;
            exit ERROR;
        }

        if (   $configuration{'iis_computer'}
            && $configuration{'iis_computer'} ne '' )
        {

            $computerName = $configuration{'iis_computer'};

        }

        if ( $configuration{'iis_port'} && $configuration{'iis_port'} ne '' ) {

            $port = $configuration{'iis_port'};

        }

        if ( $configuration{'user'} && $configuration{'user'} ne '' ) {
            $user = $configuration{'user'};
        }
        else {
#            print 'Error: Could not get user from configuration '. $gConfigName;
#            exit ERROR;
        }

        if ( $configuration{'password'} && $configuration{'password'} ne '' ) {
            $pass = $configuration{'password'};
        }
        else {
#            print 'Error: Could not get password from configuration '. $gConfigName;
#            exit ERROR;
        }

    }

    if ($ec_iis->iis_version < 7) {
        # Version 6
        push( @args, $gExecPath );

        #using vbs scripts
        push( @args, DEFAULT_CREATE_COMMAND_OPTION_IIS_6 );

        if ( $gAbsolutePhysicalPath && $gAbsolutePhysicalPath ne '' ) {

            #This parameter MUST USE backslashes!
            $gAbsolutePhysicalPath =~ s/\//\\/g;
            push( @args, '"' . $gAbsolutePhysicalPath . '"' );
        }

        if ( $gWebsite && $gWebsite ne '' ) {
            push( @args, '"' . $gWebsite . '"' );
        }

        if ( $ipAddress && $ipAddress ne '' ) {
            push( @args, '/i ' . $ipAddress );
        }

        if ( $port && $port ne '' ) {
            push( @args, '/b ' . $port );
        }

        if ( $computerName && $computerName ne '' ) {
            push( @args, '/s ' . $computerName );
        }

        if ( $user && $user ne '' ) {
            push( @args, '/u ' . $user );
        }

        if ( $pass && $pass ne '' ) {
            push( @args, '/p ' . $pass );
        }

        if ( !$gStartSite ) {
            push( @args, '/dontstart' );
        }

        if ( $gHostHeader && $gHostHeader ne '' ) {
            push( @args, '/d ' . $gHostHeader );
        }
    }
    else {
        # Version 7+
        push @args, $ec_iis->cmd_appcmd;
        push @args, qw(add site);

        if($gWebsite){
            push(@args, '/name:'. $gWebsite);
        }

        if($gBindings){
            push(@args, '/bindings:' . $gBindings);
        }

        if($gAbsolutePhysicalPath){
            push(@args, '/physicalPath:' . $gAbsolutePhysicalPath);
        }

        # TODO web site id - do something better
        if(0){
            push(@args, '/id:' . 42);
        }
    };

    #### Actually run command
    my ($content, $ret) = $ec_iis->read_cmd( \@args );
    print $content;

    #evaluates if exit was successful to mark it as a success or fail the step
    if ( !$ret ) {

        # FIXME find out if this still holds
        #set any additional error or warning conditions here
        #there may be cases in which an error occurs and the exit code is 0.
        #we want to set to correct outcome for the running step
        if ( $ec_iis->iis_version < 6 and $content !~
            m/(Status(\s+)=(\s+)STOPPED|Status(\s+)=(\s+)STARTED)/ )
        {
            print "Website could not be created.\n";
            $ec_iis->outcome_error(1);
            $ret = 255;
        }
        else {
            # version 7+
            if ($gStartSite) {
                $ret = $ec_iis->run_cmd([$ec_iis->cmd_appcmd
                    , start => site => $gWebsite])
            }
            $ec_iis->outcome_error($ret);
        }
    }
    else {
        $ec_iis->outcome_error(1);
    }

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
        print 'Error: Configuration doesn\'t exist';
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
