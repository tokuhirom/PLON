use strict;
use warnings;
use utf8;
use Test::More;
use PLSON;

is_deeply(PLSON->new->decode('[]'), []);
is_deeply(PLSON->new->decode('{}'), {});
is_deeply(PLSON->new->decode(q!{"a"=>"b"}!), {a => "b"});
is_deeply(PLSON->new->decode(q!{"a"=>"b","c" => "d"}!), {a => "b", c => "d"});
is_deeply(PLSON->new->decode('[0]'), [0]);
is_deeply(PLSON->new->decode('[3.14]'), [3.14]);

done_testing;

