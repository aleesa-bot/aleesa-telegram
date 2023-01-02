package Teapot::Bot::Object::MaskPosition;
# ABSTRACT: The base class for Telegram 'MaskPosition' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::MaskPosition::VERSION = '0.025';

has 'point';
has 'x_shift';
has 'y_shift';
has 'scale';

sub fields {
  return { scalar  => [qw/point x_shift y_shift scale/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::MaskPosition - The base class for Telegram 'MaskPosition' type objects

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram 'MaskPosition' type objects.

See L<https://core.telegram.org/bots/api#MaskPosition> for details of the
attributes available for C<Teapot::Bot::Object::MaskPosition> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2022 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
