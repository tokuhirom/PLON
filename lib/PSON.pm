package PSON;
use 5.008005;
use strict;
use warnings;
use Scalar::Util qw(blessed);

our $VERSION = "0.01";

our $INDENT;

sub new {
    my $class = shift;
    bless {
    }, $class;
}

sub encode {
    my ($self, $stuff) = @_;
    local $INDENT = 0;
    return $self->_encode($stuff);
}

sub _encode {
    my ($self, $stuff) = @_;
    local $INDENT = $INDENT + 1;

    if (blessed $stuff) {
        die "PSON.pm doesn't support blessed reference(yet?)";
    } elsif (ref($stuff) eq 'ARRAY') {
        '[' . join(',', map { $self->_encode($_) } @$stuff) . ']';
    } elsif (ref($stuff) eq 'HASH') {
        die;
    } elsif (!ref($stuff)) {
        $stuff =~ s/'/\\'/g;
        q{'} . $stuff . q{'};
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

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=cut

