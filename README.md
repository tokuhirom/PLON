# NAME

PSON - Serialize object to Perl code

# SYNOPSIS

    use PSON;

    my $pson = encode_pson([]);
    # $pson is `[]`

# DESCRIPTION

PSON is yet another serialization library for Perl5, has the JSON.pm like interface.

# WHY?

I need data dumper library supports JSON::XS/JSON::PP like interface.
I use JSON::XS really hard. Then, I want to use other serialization library with JSON::XS/JSON::PP's interface.

Data::Dumper escapes multi byte chars. When I want copy-and-paste from Data::Dumper's output to my test code, I need to un-escape `\x{5963}` by my hand. PSON.pm don't escape multi byte characters by default.

# STABILITY

This release is a prototype. Every API will change without notice.
(But, I may not remove `encode_pson($scalar)` interface. You can use this.)

I need your feedback. If you have ideas or comments, please report to [Github Issues](https://github.com/tokuhirom/PSON/issues).

# OBJECT-ORIENTED INTERFACE

The object oriented interface lets you configure your own encoding or
decoding style, within the limits of supported formats.

- $pson = PSON->new()

    Creates a new PSON object that can be used to de/encode PSON
    strings. All boolean flags described below are by default _disabled_.

- `$pson = $pson->pretty([$enabled])`

    This enables (or disables) all of the `indent`, `space_before` and
    `space_after` (and in the future possibly more) flags in one call to
    generate the most readable (or most compact) form possible.

- `$pson->ascii([$enabled])`
- `my $enabled = $pson->get_ascii()`

        $pson = $pson->ascii([$enable])

        $enabled = $pson->get_ascii

    If $enable is true (or missing), then the encode method will not generate characters outside
    the code range 0..127. Any Unicode characters outside that range will be escaped using either
    a \\x{XXXX} escape sequence.

    If $enable is false, then the encode method will not escape Unicode characters unless
    required by the PSON syntax or other flags. This results in a faster and more compact format.

        PSON->new->ascii(1)->encode([chr 0x10401])
        => ["\x{10401}"]

# PSON Spec

- PSON only supports UTF-8. Serialized PSON string must be UTF-8.
- PSON string must be eval-able.

# LICENSE

Copyright (C) Tokuhiro Matsuno.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Tokuhiro Matsuno <tokuhirom@gmail.com>
