#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/deleteVirtualDirectory.pl"
# -------------------------------------------------------------------------
# File
#    deleteVirtualDirectory.pl
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
    DEFAULT_DELETE_COMMAND_OPTION_IIS_6 => '/delete',
    DEFAULT_DELETE_COMMAND_OPTION_IIS_7 => 'delete vdir',
    CREDENTIAL_ID                       => 'credential',

    SQUOTE => q{'},
    DQUOTE => q{"},
    BSLASH => q{\\},
};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

$::gWebsite     = trim(q($[website]));
$::gConfigName  = trim(q($[configname]));
$::gVirtualPath = trim(q($[virtualpath]));
$::gExecPath    = trim(q($[execpath]));

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
    my $computerName = '';
    my $iisVersion   = '';
    my %configuration;
    my %props;

    #get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);

    # Get config TODO this should be in the module
    if ( $::gConfigName ne '' ) {
        %configuration = getConfiguration($::gConfigName);

        if ( $configuration{'iis_url'} && $configuration{'iis_url'} ne '' ) {
            $url = $configuration{'iis_url'};
        }
        else {
            print 'Error: Could not get URL from configuration '
              . $::gConfigName;
            exit ERROR;
        }

        if ( $configuration{'user'} && $configuration{'user'} ne '' ) {
            $user = $configuration{'user'};
        }
        else {
#            print 'Error: Could not get user from configuration '. $::gConfigName;
#            exit ERROR;
        }

        if ( $configuration{'password'} && $configuration{'password'} ne '' ) {
            $pass = $configuration{'password'};
        }
        else {
#            print 'Error: Could not get password from configuration '. $::gConfigName;
#            exit ERROR;
        }

        if (   $configuration{'iis_computer'}
            && $configuration{'iis_computer'} ne '' )
        {
            $computerName = $configuration{'iis_computer'};
        }

    }

    # Create command line

    if ($ec_iis->iis_version < 7) {
        push( @args, $::gExecPath );

        #using vbs scripts
        push( @args, DEFAULT_DELETE_COMMAND_OPTION_IIS_6 );

        if ( $::gVirtualPath && $::gVirtualPath ne '' ) {
            push( @args, $::gWebsite . '/' . $::gVirtualPath );
        }
        else {
            push( @args, $::gWebsite );
        }

        if ( $computerName && $computerName ne '' ) {
            push( @args, '/s' , $computerName );
        }

        if ( $user && $user ne '' ) {
            push( @args, '/u' , $user );
        }

        if ( $pass && $pass ne '' ) {
            push( @args, '/p' , $pass );
        }
    }
    else {
        # iis 7+ - other cmd
        $::gAppName = $ec_iis->get_ec->getProperty("appname")->findvalue("//value");
        push @args, $ec_iis->cmd_appcmd;
        push @args, 'delete', 'vdir', '/vdir.name:'.$::gAppName;
    };

    my ($content, $ret) = $ec_iis->read_cmd( @args );

    print $content;

    if ( !$ret ) {
        $ec->setProperty( "/myJobStep/outcome", 'success' );

        # FIXME Find out whether this is still true
        #set any additional error or warning conditions here
        #there may be cases in which an error occurs and the exit code is 0.
        #we want to set to correct outcome for the running step
        if ( $content =~ m/The virtual directory (.+) does not exist/ ) {
            $ec->setProperty( "/myJobStep/outcome", 'error' );
            $ret = 255;
        }

    }
    else {
        $ec->setProperty( "/myJobStep/outcome", 'error' );
    };
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
