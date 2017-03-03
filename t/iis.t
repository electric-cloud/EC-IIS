use Test::More tests => 3;
BEGIN {
    use File::Basename;
    my $lib = dirname($0) . '/../src/main/resources/project/lib';
    push @INC, $lib;
}

use_ok('EC::IIS');
use_ok('EC::Plugin::IISDriver');


my $map = {key => 'value', key1 => {key3 => 'value'}};
my $flat_map = EC::IIS::_flatten_map($map);

is_deeply($flat_map, {'/key' => 'value', '/key1/key3' => 'value'});
