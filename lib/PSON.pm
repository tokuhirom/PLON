package PSON;
use 5.008005;
use strict;
use warnings;
use Scalar::Util qw(blessed);
use parent qw(Exporter);
use B;
use Encode ();

our $VERSION = "0.01";

our @EXPORT = qw(encode_pson);

our $INDENT;

sub new {
    my $class = shift;
    bless {
    }, $class;
}

sub ascii {
    if (@_ == 1) {
        $_[0];
    } else {
        $_[0]->{ascii} = $_[1];
        $_[0];
    }
}

sub encode {
    my ($self, $stuff) = @_;
    local $INDENT = 0;
    return $self->_encode($stuff);
}

sub _encode {
    my ($self, $value) = @_;
    local $INDENT = $INDENT + 1;

    if (blessed $value) {
        die "PSON.pm doesn't support blessed reference(yet?)";
    } elsif (ref($value) eq 'ARRAY') {
        '[' . join(',', map { $self->_encode($_) } @$value) . ']';
    } elsif (ref($value) eq 'HASH') {
        '{' . join(',', map { $self->_encode($_) . '=>' . $self->_encode($value->{$_}) } keys %$value) . '}';
    } elsif (!ref($value)) {
        my $flags = B::svref_2object(\$value)->FLAGS;
        return 0 + $value if $flags & (B::SVp_IOK | B::SVp_NOK) && $value * 0 == 0;

        # string
        if ($self->{ascii}) {
            $value =~ s/'/\\'/g;
            if (Encode::is_utf8($value)) {
                my $buf = '';
                for (split //, $value) {
                    if ($_ =~ /\A[a-zA-Z0-9_ -]\z/) {
                        $buf .= Encode::encode_utf8($_);
                    } else {
                        $buf .= sprintf "\\x{%X}", ord $_;
                    }
                }
               $value = $buf;
            } else {
                $value = $value;
            }
            q{'} . $value . q{'};
        } else {
            $value =~ s/'/\\'/g;
            $value = Encode::is_utf8($value) ? Encode::encode_utf8($value) : $value;
            q{'} . $value . q{'};
        }
    } else {
        die "Unknown type";
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

PSON - It's new $module

=head1 SYNOPSIS

    use PSON;

=head1 DESCRIPTION

PSON is ...

=head1 PSON and Unicode

PSON only supports UTF-8. It must be UTF-8.

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=cut

