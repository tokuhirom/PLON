use strict;
use warnings;
use utf8;
use Test::More;
use PLON;

is(PLON->new->encode(bless([9], 'X')), 'bless([9,],"X")');
is(PLON->new->encode(bless({a=>9}, 'X')), 'bless({"a"=>9,},"X")');

done_testing;

