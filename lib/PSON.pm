package PSON;
use 5.008005;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use parent qw(Exporter);
use B;
use Encode ();

our $VERSION = "0.02";

our @EXPORT = qw(encode_pson);

our $INDENT;

my $WS = qr{[ \t]*};

sub mk_accessor {
    my ($pkg, $name) = @_;

    no strict 'refs';
    *{"${pkg}::${name}"} = sub {
        my $enable = defined($_[1]) ? $_[1] : 1;
        if ($enable) {
            $_[0]->{$name} = 1;
        } else {
            $_[0]->{$name} = 0;
        }
        $_[0];
    };
    *{"${pkg}::get_${name}"} = sub {
        $_[0]->{$name} ? 1 : '';
    };
}

sub new {
    my $class = shift;
    bless {
    }, $class;
}

mk_accessor(__PACKAGE__, $_) for qw(pretty ascii);

sub encode {
    my ($self, $stuff) = @_;
    local $INDENT = -1;
    return $self->_encode($stuff);
}

sub _encode {
    my ($self, $value) = @_;
    local $INDENT = $INDENT + 1;

    if (blessed $value) {
        die "PSON.pm doesn't support blessed reference(yet?)";
    } elsif (ref($value) eq 'ARRAY') {
        join('',
            '[',
            $self->_nl,
            (map { $self->_indent(1) . $self->_encode($_) . "," . $self->_nl }
                @$value),
            $self->_indent,
            ']',
        );
    } elsif (ref($value) eq 'HASH') {
        join('',
            '{',
            $self->_nl,
            (map {
                    $self->_indent(1) . $self->_encode($_)
                      . $self->_before_sp . '=>' . $self->_after_sp
                      . $self->_encode($value->{$_})
                      . "," . $self->_nl,
                  }
                  keys %$value),
            $self->_indent,
            '}',
        );
    } elsif (!ref($value)) {
        my $flags = B::svref_2object(\$value)->FLAGS;
        return 0 + $value if $flags & (B::SVp_IOK | B::SVp_NOK) && $value * 0 == 0;

        # string
        if ($self->{ascii}) {
            $value =~ s/"/\\"/g;
            if (Encode::is_utf8($value)) {
                my $buf = '';
                for (split //, $value) {
                    if ($_ =~ /\G[a-zA-Z0-9_ -]\z/) {
                        $buf .= Encode::encode_utf8($_);
                    } else {
                        $buf .= sprintf "\\x{%X}", ord $_;
                    }
                }
               $value = $buf;
            } else {
                $value = $value;
            }
            q{"} . $value . q{"};
        } else {
            #
            # Here is the list of special characters from perlop.pod
            #
            # Sequence     Note  Description
            # \t                  tab               (HT, TAB)
            # \n                  newline           (NL)
            # \r                  return            (CR)
            # \f                  form feed         (FF)
            # \b                  backspace         (BS)
            # \a                  alarm (bell)      (BEL)
            # \e                  escape            (ESC)
            # \x{263A}     [1,8]  hex char          (example: SMILEY)
            # \x1b         [2,8]  restricted range hex char (example: ESC)
            # \N{name}     [3]    named Unicode character or character sequence
            # \N{U+263D}   [4,8]  Unicode character (example: FIRST QUARTER MOON)
            # \c[          [5]    control char      (example: chr(27))
            # \o{23072}    [6,8]  octal char        (example: SMILEY)
            # \033         [7,8]  restricted range octal char  (example: ESC)
            #
            my %special_chars = (
                qq{"}  => q{\"},
                qq{\t} => q{\t},
                qq{\n} => q{\n},
                qq{\r} => q{\r},
                qq{\f} => q{\f},
                qq{\b} => q{\b},
                qq{\a} => q{\a},
                qq{\e} => q{\e},
                q{$}   => q{\$},
                q{@}   => q{\@},
                q{%}   => q{\%},
                q{\\}  => q{\\\\},
            );
            $value =~ s/(.)/
                if (exists($special_chars{$1})) {
                    $special_chars{$1};
                } else {
                    $1
                }
            /gexs;
            $value = Encode::is_utf8($value) ? Encode::encode_utf8($value) : $value;
            q{"} . $value . q{"};
        }
    } else {
        die "Unknown type";
    }
}

sub _indent {
    my ($self, $n) = @_;
    if (not defined $n) { $n = 0 };
    $self->get_pretty ? '  ' x ($INDENT+$n) : ''
}

sub _nl {
    my $self = shift;
    $self->get_pretty ? "\n" : '',
}

sub _before_sp {
    my $self = shift;
    $self->get_pretty ? " " : ''
}

sub _after_sp {
    my $self = shift;
    $self->get_pretty ? " " : ''
}

sub decode {
    my ($self, $src) = @_;
    local $_ = $src;
    return $self->_decode();
}

sub _decode {
    my ($self) = @_;

    if (/\G$WS\{/gc) {
        return $self->_decode_hash();
    } elsif (/\G$WS\[/gc) {
        return $self->_decode_array();
    } elsif (/\G$WS"/gc) {
        return $self->_decode_string();
    } else {
        die "Unexpected token: " . substr($_, 0, 2);
    }
}

sub _decode_hash {
    my ($self) = @_;

    my %ret;
    until (/\G$WS(,$WS)?\}/gc) {
        my $k = $self->_decode_term();
        /\G$WS=>$WS/gc
            or _exception("Unexpected token in Hash");
        my $v = $self->_decode_term();

        $ret{$k} = $v;

        /\G$WS,/gc
            or last;
    }
    return \%ret;
}

sub _decode_array {
    my ($self) = @_;

    my @ret;
    until (/\G$WS,?$WS\]/gc) {
        my $term = $self->_decode_term();
        push @ret, $term;
    }
    return \@ret;
}

sub _decode_term {
    my ($self) = @_;

    if (/\G$WS"/gc) {
        return $self->_decode_string;
    } elsif (/\G$WS([0-9\.]+)/gc) {
        0+$1;
    } else {
        _exception("Not a term");
    }
}

sub _decode_string {
    my $self = shift;

    my $ret;
    until (/\G"/gc) {
        if (/\G\\"/gc) {
            $ret .= q{"};
        } elsif (/\G\\\$/gc) {
            $ret .= qq{\$};
        } elsif (/\G\\t/gc) {
            $ret .= qq{\t};
        } elsif (/\G\\n/gc) {
            $ret .= qq{\n};
        } elsif (/\G\\r/gc) {
            $ret .= qq{\r};
        } elsif (/\G\\f/gc) {
            $ret .= qq{\f};
        } elsif (/\G\\b/gc) {
            $ret .= qq{\b};
        } elsif (/\G\\a/gc) {
            $ret .= qq{\a};
        } elsif (/\G\\e/gc) {
            $ret .= qq{\e};
        } elsif (/\G\\$/gc) {
            $ret .= qq{\$};
        } elsif (/\G\\@/gc) {
            $ret .= qq{\@};
        } elsif (/\G\\%/gc) {
            $ret .= qq{\%};
        } elsif (/\G\\\\/gc) {
            $ret .= qq{\\};
        } elsif (/\G\\x\{([0-9a-fA-F]+)\}/gc) { # \x{5963}
            $ret .= chr(hex $1);
        } elsif (/\G([^"\\]+)/gc) {
            $ret .= $1;
        } else {
            _exception("Unexpected EOF in string");
        }
    }
    # If it's utf-8, it means the PSON encoded by ASCII mode.
    # The PSON contains "\x{5963}". Then, we shouldn't decode the string.
    return Encode::is_utf8($ret) ? $ret : Encode::decode_utf8($ret);
}

sub _exception {

  # Leading whitespace
  m/\G$WS/gc;

  # Context
  my $context = 'Malformed PSON: ' . shift;
  if (m/\G\z/gc) { $context .= ' before end of data' }
  else {
    my @lines = split "\n", substr($_, 0, pos);
    $context .= ' at line ' . @lines . ', offset ' . length(pop @lines || '');
  }

  die "$context\n";
}

1;
__END__

=encoding utf-8

=head1 NAME

PSON - Serialize object to Perl code

=head1 SYNOPSIS

    use PSON;

    my $pson = encode_pson([]);
    # $pson is `[]`

=head1 DESCRIPTION

PSON is yet another serialization library for Perl5, has the JSON.pm like interface.

=head1 WHY?

I need data dumper library supports JSON::XS/JSON::PP like interface.
I use JSON::XS really hard. Then, I want to use other serialization library with JSON::XS/JSON::PP's interface.

Data::Dumper escapes multi byte chars. When I want copy-and-paste from Data::Dumper's output to my test code, I need to un-escape C<\x{5963}> by my hand. PSON.pm don't escape multi byte characters by default.

=head1 STABILITY

This release is a prototype. Every API will change without notice.
(But, I may not remove C<encode_pson($scalar)> interface. You can use this.)

I need your feedback. If you have ideas or comments, please report to L<Github Issues|https://github.com/tokuhirom/PSON/issues>.

=head1 OBJECT-ORIENTED INTERFACE

The object oriented interface lets you configure your own encoding or
decoding style, within the limits of supported formats.

=over 4

=item $pson = PSON->new()

Creates a new PSON object that can be used to de/encode PSON
strings. All boolean flags described below are by default I<disabled>.

=item C<< $pson = $pson->pretty([$enabled]) >>

This enables (or disables) all of the C<indent>, C<space_before> and
C<space_after> (and in the future possibly more) flags in one call to
generate the most readable (or most compact) form possible.

=item C<< $pson->ascii([$enabled]) >>

=item C<< my $enabled = $pson->get_ascii() >>

    $pson = $pson->ascii([$enable])

    $enabled = $pson->get_ascii

If $enable is true (or missing), then the encode method will not generate characters outside
the code range 0..127. Any Unicode characters outside that range will be escaped using either
a \x{XXXX} escape sequence.

If $enable is false, then the encode method will not escape Unicode characters unless
required by the PSON syntax or other flags. This results in a faster and more compact format.

    PSON->new->ascii(1)->encode([chr 0x10401])
    => ["\x{10401}"]

=back

=head1 PSON Spec

=over 4

=item PSON only supports UTF-8. Serialized PSON string must be UTF-8.

=item PSON string must be eval-able.

=back

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=cut

