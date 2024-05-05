#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use WWW::WolframAlpha;

my $res = wolfram-alpha-query('convert 230 lbs into kilograms');

say $res;

