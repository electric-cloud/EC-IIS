# -------------------------------------------------------------------------
   # File
   #    startServer.pl
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
   use Data::Dumper;

   BEGIN {
      # line 1 "preamble.pl"
      $[/myProject/preamble];
   }
   # line 37 "startServer.pl"
   
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
       START_COMMAND => '/start',
       CREDENTIAL_ID => 'credential',
       
  };
  
  ########################################################################
  # trim - deletes blank spaces before and after the entered value in 
  # the argument
  #
  # Arguments:
  #   -untrimmedString: string that will be trimmed
  #
  # Returns:
  #   trimmed string
  #
  ########################################################################  
  sub trim($) {
      my $string = shift;
      
      # kill leading & trailing spaces
      $string =~ s/^\s+//;
      $string =~ s/\s+$//;
      
      return $string;
  }
  
  # -------------------------------------------------------------------------
  # Variables
  # -------------------------------------------------------------------------
  
  $::gExecPath = "$[execpath]";
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
    my @args;
    my %configuration;
    
    my $iisVersion = '';
    my $url = '';
    my $user = '';
    my $password = '';
    
    if(!defined $::gConfigName || !length $::gConfigName){
        warn "Config not found";
        exit ERROR;
    }
    %configuration = getConfiguration($::gConfigName);
    
    #inject config...
    if($configuration{'iis_url'} && $configuration{'iis_url'} ne ''){
        $url = $configuration{'iis_url'};
    }else{
        warn "no iis_url in config";
        exit ERROR;
    }
 
    if(defined $configuration{'user'} and defined $configuration{'password'}) {
        $user = $configuration{'user'};
        $password = $configuration{'password'};
    }
    
    #commands to be executed for version 6
    push(@args, $::gExecPath);
    push(@args, START_COMMAND);
    
    #generate command line
    my $cmdLine = join( " ", @args );
    
    if(-f $::gExecPath) {
        #execute command line
        my $ret = system(@args);
        
        #show masked command line
        print "Command Line: $cmdLine\n";
        
        #set prop's hash to EC properties
        setProperties({cmdLine => $cmdLine});
    }
    else {
        print "Error: failed to find executable at '$::gExecPath'";
        exit ERROR;
    };
  }; # end main
  
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
            die "No config for '$proj' named '$configName'";
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
