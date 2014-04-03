use strict;
use warnings;
use utf8;
use Test::More;
use PLSON;

is(PLSON->new->encode(sub { }), 'sub { "DUMMY" }');
like(PLSON->new->deparse->encode(sub { 1 }), qr!\Asub \{\s*.*;1;\s*\}\z!);

eval {
    PLSON->new->decode('sub { }')
};
like $@, qr/Cannot decode PLSON contains CodeRef./;

done_testing;

