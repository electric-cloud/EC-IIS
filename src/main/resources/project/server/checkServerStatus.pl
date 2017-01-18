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
   $|=1;
   
   # -------------------------------------------------------------------------
   # Constants
   # -------------------------------------------------------------------------
   use constant {
       SUCCESS => 0,
       ERROR   => 1,
       
       PLUGIN_NAME => 'EC-IIS',
       CREDENTIAL_ID => 'credential',
       CHECK_COMMAND => '/status',
       
       GENERATE_REPORT => 1,
       DO_NOT_GENERATE_REPORT => 0,
   
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
  #########################################################################
  sub trim($) {
   
      my ($untrimmedString) = @_;
      
      my $string = $untrimmedString;
      
      #removes leading spaces
      $string =~ s/^\s+//;
      
      #removes trailing spaces
      $string =~ s/\s+$//;
      
      #returns trimmed string
      return $string;
  }  
  
  # -------------------------------------------------------------------------
  # Variables
  # -------------------------------------------------------------------------
  
  $::gUseCredentials = "$[usecredentials]";
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
    
    my $url = '';
    my $port = '';
    my $user = '';
    my $pass = '';
    my %configuration;
    
    if($::gConfigName ne ''){
        %configuration = getConfiguration($::gConfigName);
        
        if($configuration{'iis_url'} && $configuration{'iis_url'} ne ''){
            $url = $configuration{'iis_url'};
        }else{
            print 'Could not get URL from configuration '. $::gConfigName;
            exit ERROR;
        }
        
        if($configuration{'iis_port'} && $configuration{'iis_port'} ne ''){
            $port = $configuration{'iis_port'};
        }
        if($::gUseCredentials){
            if($configuration{'user'} && $configuration{'user'} ne ''){
                $user = $configuration{'user'};
            }else{
#                print 'Could not get user from configuration '. $::gConfigName;
#                exit ERROR;
            }
        }
        if($configuration{'password'} && $configuration{'password'} ne ''){
            $pass = $configuration{'password'};
        }else{
#            print 'Could not get password from configuration '. $::gConfigName;
#            exit ERROR;
        }
        
    }
        
    #commands to be executed for version 6
    push(@args, 'iisreset');
        
    push(@args, CHECK_COMMAND);
 
    #generate command line
    my $cmdLine = createCommandLine(\@args);
    
    if($cmdLine && $cmdLine ne ''){
     
        #execute command line
        system($cmdLine);
        
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
          print "Error: Configuration doesn\'t exist\n";
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
