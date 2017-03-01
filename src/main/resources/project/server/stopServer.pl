#$[/myProject/preamble]
use strict;
use warnings;
use EC::IIS;

my $ec_iis = EC::IIS->new;
my $extras = $ec_iis->get_param("additionalParams");
my $command = $extras ? "/stop $extras" : '/stop';
exit $ec_iis->run_reset($command);
