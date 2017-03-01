#$[/myProject/preamble]
use strict;
use warnings;
use EC::IIS;

my $ec_iis = EC::IIS->new;
exit $ec_iis->run_reset( '/stop' );
