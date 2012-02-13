# $[/myProject/IISServer.pm]

package Main;
use Test::More tests => 2;
use Data::Dumper;
use lib '../../agent/lib';
use IISServer;

my $server = IISServer->new();
ok(defined($server), 'Instantiated Server');
$server->configure('iis6test');
is($server->configurationName, 'iis6test', 'Config Correct');
print Dumper($server);