use strict;
use warnings;
use Test::More;
use Data::Dumper;
use PSON;
use Encode;

subtest 'Normal mode', sub {
    # Given UTF-8 string.
    my $src = "\x{3042}";
    # WHen encode to PSON
    my $pson = PSON->new->encode($src);
    # Then response is encoded
    ok !Encode::is_utf8($pson);
    # And response is 'あ'
    is $pson, encode_utf8("'\x{3042}'");
};

subtest 'Ascii mode', sub {
    # Given UTF-8 string.
    my $src = "\x{3042}a";
    # WHen encode to PSON
    my $pson = PSON->new->ascii(1)->encode($src);
    # Then response is encoded
    ok !Encode::is_utf8($pson);
    # And response is 'あ'
    is $pson, q{'\x{3042}a'};
};

done_testing;

