#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use WWW::WolframAlpha;

# my $res = wolfram-alpha-query('convert 230 lbs into kilograms', path => 'query');
#say $res;

#`[
my $res = wolfram-alpha-simple('convert 230 lbs into kilograms');

say $res;
]

my $res = wolfram-alpha-result('convert 230 lbs', units => 'metric');

say $res;
