use strict;
use warnings;
use utf8;
use Test::More;
use PSON;

is encode_pson([]), '[]';

done_testing;

