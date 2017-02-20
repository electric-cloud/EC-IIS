$[/myProject/preamble]

use ElectricCommander;
use ElectricCommander::PropDB;
use strict;
use warnings;

use Carp;
use Data::Dumper;
use EC::IIS;

my $iis = EC::IIS->new;

my $params = $iis->get_params_as_hashref(qw/
    msdeployPath verb sourceProvider
    sourceProviderObjectPath sourceProviderSettings destProvider
    destProviderObjectPath destProviderSettings allowUntrusted
    preSync postSync
    additionalOptions
    setParamFile declareParamFile/
);

# TODO param file

my $command = $iis->create_msdeploy_command($params);
$iis->set_cmd_line($command);

my $result = $iis->run_command($command);
if ($result->{code} != 0) {
    $iis->bail_out("Error: $result->{stderr}");
}
else {
    print $result->{stdout};
}


