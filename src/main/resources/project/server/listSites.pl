# $[/myProject/preamble]
use strict;
use warnings;
use EC::IIS;

my $iis = EC::IIS->new;
$iis->step_list_sites;
