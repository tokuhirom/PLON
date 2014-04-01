use strict;
use warnings;
use utf8;
use Test::More;
use PSON;

is_deeply(PSON->new->decode('[]'), []);
is_deeply(PSON->new->decode('{}'), {});
is_deeply(PSON->new->decode(q!{"a"=>"b"}!), {a => "b"});
is_deeply(PSON->new->decode(q!{"a"=>"b","c" => "d"}!), {a => "b", c => "d"});
is_deeply(PSON->new->decode('[0]'), [0]);
is_deeply(PSON->new->decode('[3.14]'), [3.14]);

done_testing;

