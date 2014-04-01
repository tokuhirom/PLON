use strict;
use warnings;
use utf8;
use Test::More;
use PSON;

my $pson = PSON->new->pretty(1)->encode([
    {a => [ qw(x y z)]},
]);
is $pson, n(<<'...');
[
  {
    "a" => [
      "x",
      "y",
      "z",
    ],
  },
]
...

{
my $pson = PSON->new->pretty(1)->encode({
    x => [a => [ qw(x y z)]],
});
is $pson, n(<<'...');
{
  "x" => [
    "a",
    [
      "x",
      "y",
      "z",
    ],
  ],
}
...
}

done_testing;

# normalize
sub n {
    my $n = shift;
    $n =~ s/\n\z//;
    $n;
}
