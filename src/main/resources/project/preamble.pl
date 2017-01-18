#!/usr/bin/env perl
# line 3 "preamble.pl"

use strict;
use warnings;

use Carp;

use ElectricCommander;
use ElectricCommander::PropDB;
$|=1;

my $ec = ElectricCommander->new;
my $prefix = '/myProject/';

# TODO This should be in EC core
my $load = sub {
    my $target = shift;

    my $prop = "$prefix$target";
    my $code = $ec->getProperty("$prop")->findvalue('//value')->string_value;
    croak "Failed to load $target: property $prop empty"
        unless $code;

    my $ret = do {
        no strict;
        no warnings;
        eval qq{# line 1 "$prop"\n$code};
    };

    croak "Failed to load $target from property $prop: "
        . ( $@ || "code didn't return a true value" )
            unless $ret;

    $target =~ s#::#/#g;
    $target .= ".pm";
    $INC{$target} = $prop; # avoid reloading

    return $ret;
};

$load->("EC::IIS");
