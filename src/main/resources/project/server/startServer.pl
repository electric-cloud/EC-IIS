#$[/myProject/preamble]
use strict;
use warnings;
use EC::IIS;

my $iis = EC::IIS->new;
$iis->run_reset('/start');
