package IISServer;

use strict;
use warnings;
use base qw(Class::Accessor);

use ElectricCommander;
use ElectricCommander::PropDB;

use constant {
    SUCCESS => 0,
    ERROR   => 1,
    PLUGIN_NAME => 'EC-IIS',
    VERSION => '0.01a',
    CREDENTIAL_ID => 'credential', # to prevent re-reading property into the object during configure()
};

=pod

=head1 NAME

    IISServer - An abstraction of the IIS Server

=head1 SYNOPSIS

    my $iis = IISServer->new();
    $iis->configure('iis6test');

=head1 DESCRIPTION

    Create a new object from a Commander plugin configuration, then use the methods provided to manipulate the Server, Web Sites, and Virtual Directories.

=head1 METHODS

    configure('configurationname')

=cut

=pod

=head2 new

  my $object = IISServer->new(
  );

The C<new> constructor lets you create a new B<IISServer> object.

Returns a new B<IISServer> or dies on error.

=cut

# Deriving from Class::Accessor, this takes the place of a constructor method and generates accessors and new()
# Make sure each property in the configuration is included in this list!
IISServer->mk_accessors(qw(configurationName user password credential iis_computer iis_port iis_url iisversion));

=pod

=head2 configure

Set the configuration to use, and get the elements out of the configuration.

=cut

sub configure($){
    my $self = shift;
    my ($conf) = @_;

    $self->configurationName($conf);

    # get an EC object
    my $ec = new ElectricCommander();
    $ec->abortOnError(0);

    my $proj = "$[/myProject/projectName]";
    my $pluginConfigs = new ElectricCommander::PropDB($ec,"/projects/$proj/iis_cfgs");

    my %configRow = $pluginConfigs->getRow($self->configurationName);

    # Check if configuration exists
    unless(keys(%configRow)) {
      print 'Error: Configuration doesn\'t exist';
      exit ERROR;
    }

    # Get user/password out of credential
    my $xpath = $ec->getFullCredential($configRow{credential});
    $self->user($xpath->findvalue("//userName")->value());
    $self->password($xpath->findvalue("//password")->value());

    foreach my $cr (keys %configRow) {
      
      #getting all values except the credential that was read previously
      if($cr ne CREDENTIAL_ID){
          $self->$cr($configRow{$cr});
      }
    }
    return;
}

1;

=pod

=head2 registerReports

Creates a link for registering the generated report in the job step detail

reportFilename: name of the archive which will be linked to the job detail

reportName: name which will be given to the generated linked report

=cut
  sub registerReports($){
      
      my ($reportFilename, $reportName) = @_;
      
      if($reportFilename && $reportFilename ne ''){    
          
          # get an EC object
          my $ec = new ElectricCommander();
          $ec->abortOnError(0);
          
          $ec->setProperty("/myJob/artifactsDirectory", '');
                  
          $ec->setProperty("/myJob/report-urls/" . $reportName, 
             "jobSteps/$[jobStepId]/" . $reportFilename);
              
      }
            
  }
  
  
  # This should be done with Perl's File::Spec functions !!!
  sub fixPath($){
   
     my ($absPath) = @_;
     
     my $separator;
     
     if(!$absPath || $absPath eq ''){
        return '';
     }
     
     if((substr($absPath, length($absPath)-1,1) eq '\\') ||
         substr($absPath, length($absPath)-1,1) eq '/'){
          
          return $absPath;
          
     }
     
     if($absPath =~ m/.*\/.+/){
         
         $separator = '/';
         
     }elsif($absPath =~ m/.+\\.+/) {
       
         $separator = "\\";
      
     }else{
        exit ERROR;
     }
     
     my $fixedPath = $absPath . $separator;
    
     
     return $fixedPath;
   
  }

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

    my ($untrimmedString) = @_;

    my $string = $untrimmedString;

    #removes leading spaces
    $string =~ s/^\s+//;

    #removes trailing spaces
    $string =~ s/\s+$//;

    #returns trimmed string
    return $string;
}

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Written by Ed Cardinal
Copyright 2011 Electric Cloud, Inc.

=cut
