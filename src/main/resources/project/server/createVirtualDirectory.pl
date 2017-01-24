#!/usr/bin/env perl
# include $[/myProject/preamble]
# line 4 "@PLUGIN_KEY@-@PLUGIN_VERSION@/createVirtualDirectory.pl"
# -------------------------------------------------------------------------
# File
#    createVirtualDirectory.pl
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
use diagnostics;
use Cwd;
use File::Spec;

use ElectricCommander;
use ElectricCommander::PropDB;
use EC::IIS qw(trim);
$|=1;
 
 # -------------------------------------------------------------------------
 # Constants
 # -------------------------------------------------------------------------
 use constant {
     SUCCESS => 0,
     ERROR   => 1,
     
     PLUGIN_NAME => 'EC-IIS',
     WIN_IDENTIFIER => 'MSWin32',
     IIS_VERSION_6 => 'iis6',
     IIS_VERSION_7 => 'iis7',
     DEFAULT_CREATE_COMMAND_OPTION_IIS_6 => '/create',
     DEFAULT_CREATE_COMMAND_OPTION_IIS_7 => 'add vdir',
     CREDENTIAL_ID => 'credential',
     
     SQUOTE => q{'},
     DQUOTE => q{"},
     BSLASH => q{\\},
};

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

$::gWebsite = trim(q($[website]));
$::gAbsolutePhysicalPath = trim(q($[absolutephysicalpath]));
$::gConfigName= trim(q($[configname]));
$::gVirtualDirName = trim(q($[virtualdirname]));
$::gVirtualPath = trim(q($[virtualpath]));
$::gExecPath = trim(q($[execpath]));



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
 
  my @args = ();
  my $url = '';
  my $computerName = '';
  my $user = '';
  my $pass = '';
  my $iisVersion = '';
  my %configuration;
  my %props;
  
   #get an EC object
  my $ec = new ElectricCommander();
  $ec->abortOnError(0);
  
  if($::gConfigName ne ''){
      %configuration = getConfiguration($::gConfigName);
      
      if($configuration{'iis_url'} && $configuration{'iis_url'} ne ''){
          $url = $configuration{'iis_url'};
      }else{
          print 'Error: Could not get URL from configuration '. $::gConfigName;
          exit ERROR;
      }
      
      if($configuration{'user'} && $configuration{'user'} ne ''){
          $user = $configuration{'user'};
      }else{
#            print 'Error: Could not get user from configuration '. $::gConfigName;
#            exit ERROR;
      }
      
      if($configuration{'password'} && $configuration{'password'} ne ''){
          $pass = $configuration{'password'};
      }else{
#            print 'Error: Could not get password from configuration '. $::gConfigName;
#            exit ERROR;
      }
      
      if($configuration{'iis_computer'} && $configuration{'iis_computer'} ne ''){
          $computerName = $configuration{'iis_computer'};
      }
      
      
      
  }
  
  push(@args, '"' . $::gExecPath . '"');
  
  
      #using vbs scripts
      push(@args, DEFAULT_CREATE_COMMAND_OPTION_IIS_6);
      
      if($::gVirtualPath && $::gVirtualPath ne ''){
          push(@args, '"' . $::gWebsite . '/'. $::gVirtualPath . '"');
      }else{
          push(@args, '"' . $::gWebsite . '"');
      }
      
      if($::gVirtualDirName && $::gVirtualDirName ne ''){
          push(@args, $::gVirtualDirName);
      }
      
      if($::gAbsolutePhysicalPath && $::gAbsolutePhysicalPath ne ''){
          push(@args, '"' . $::gAbsolutePhysicalPath . '"');
      }
      
      if($computerName && $computerName ne ''){
          push(@args, '/s ' . $computerName);
      }
      
      if($user && $user ne ''){
          push(@args, '/u ' . $user);
      }
      
      if($pass && $pass ne ''){
          push(@args, '/p ' . $pass);
      }
      
  
  
  #generate command line
  my $cmdLine = createCommandLine(\@args);
  my $content = '';
  
  if($cmdLine && $cmdLine ne ''){
   
      #execute command line
      $content = `$cmdLine`;
      
      print $content;
      
      #evaluates if exit was successful to mark it as a success or fail the step
      if($? == SUCCESS){
       
          $ec->setProperty("/myJobStep/outcome", 'success');
          
          #set any additional error or warning conditions here
          #there may be cases in which an error occurs and the exit code is 0.
          #we want to set to correct outcome for the running step
          if($content !~ m/Virtual Path/){
              #license expired warning
              print "Virtual directory could not be created. See log for more details.\n";
              $ec->setProperty("/myJobStep/outcome", 'error');
          }
          
      }else{
          $ec->setProperty("/myJobStep/outcome", 'error');
      }
      
      #mask password
      $cmdLine =~ s/ \/p (\S+)/ \/p \*\*\*\*/;
      
      #show masked command line
      print "Command Line: $cmdLine\n";
      
      #add masked command line to properties object
      $props{'cmdLine'} = $cmdLine;
      
      #set prop's hash to EC properties
      setProperties(\%props);
   
  }else{
   
      print "Error: could not generate command line";
      exit ERROR;
   
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
    
    foreach my $key (keys % $propHash) {
        my $val = $propHash->{$key};
        $ec->setProperty("/myCall/$key", $val);
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
sub getConfiguration($){
 
    my ($configName) = @_;
    
    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);
    
    my %configToUse;
    
    my $proj = "$[/myProject/projectName]";
    my $pluginConfigs = new ElectricCommander::PropDB($ec,"/projects/$proj/iis_cfgs");
    
    my %configRow = $pluginConfigs->getRow($configName);
    
    # Check if configuration exists
    unless(keys(%configRow)) {
        print 'Error: Configuration doesn\'t exist';
        exit ERROR;
    }
    
    # Get user/password out of credential
    my $xpath = $ec->getFullCredential($configRow{credential});
    $configToUse{'user'} = $xpath->findvalue("//userName");
    $configToUse{'password'} = $xpath->findvalue("//password");
    
    foreach my $c (keys %configRow) {
        
        #getting all values except the credential that was read previously
        if($c ne CREDENTIAL_ID){
            $configToUse{$c} = $configRow{$c};
        }
        
    }
   
    return %configToUse;
 
}

main();
 
1;
