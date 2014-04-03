use strict;
use warnings;
use utf8;
use Test::More;
use PSON;

is(PSON->new->encode(sub { }), 'sub { "DUMMY" }');
like(PSON->new->deparse->encode(sub { 1 }), qr!\Asub \{\s*.*;1;\s*\}\z!);

eval {
    PSON->new->decode('sub { }')
};
like $@, qr/Cannot decode PSON contains CodeRef./;

done_testing;

