use v6.d;

use lib '.';
use lib './lib';

use WWW::WolframAlpha;
use Test;

my $method = 'tiny';

plan *;

## 1
ok wolfram-alpha-result('convert 23 feet and 43 inches', units => 'metric');

## 2
ok wolfram-alpha-simple('convert 23 feet and 43 inches', units => 'metric');

## 3
ok wolfram-alpha-query('convert 44 lbs to kilograms', output => 'json', format => 'hash');

## 4
ok wolfram-alpha('convert 23 feet and 43 inches', units => 'metric', path => 'result');

done-testing;
