use strict;
use warnings;
use Test::More;
use Test::Base::Less;
use PSON;

filters {
    input => ['eval'],
};

my $pson = PSON->new();
for my $block (blocks) {
    subtest $block->expected, sub {
        my $got = $pson->encode($block->input);
        is $got, $block->expected;
        is_deeply eval($got), $block->input;
     };
}

done_testing;

__DATA__

===
--- input: []
--- expected: []

===
--- input: ['a']
--- expected: ['a']

===
--- input: ['a\'']
--- expected: ['a\'']

===
--- input: {x => 'y'}
--- expected: {'x'=>'y'}

===
--- input: [0]
--- expected: [0]


