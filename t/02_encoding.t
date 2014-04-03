use strict;
use warnings;
use Test::More;
use Data::Dumper;
use PLSON;
use Encode;

subtest 'Normal mode', sub {
    # Given UTF-8 string.
    my $src = "\x{3042}";
    # When encode to PLSON
    my $pson = PLSON->new->encode($src);
    # Then response is encoded
    ok !Encode::is_utf8($pson);
    # And response is 'あ'
    is $pson, encode_utf8(qq!"\x{3042}"!);
    # When decode the response,
    my $decoded = PLSON->new->decode($pson);
    # Then got a original source.
    is $decoded, $src;
    # You can decode with 'eval'.
    is eval "use utf8; $pson", $src;
};

subtest 'Ascii mode', sub {
    # Given UTF-8 string.
    my $src = "\x{3042}a";
    # WHen encode to PLSON
    my $pson = PLSON->new->ascii(1)->encode($src);
    # Then response is encoded
    ok !Encode::is_utf8($pson);
    # And response is 'あ'
    is $pson, q{"\x{3042}a"};
    # When decode the response,
    my $decoded = PLSON->new->decode($pson);
    # Then got a original source.
    is $decoded, $src;
    # You can decode with 'eval'.
    is eval "use utf8; $pson", $src;
};

done_testing;

