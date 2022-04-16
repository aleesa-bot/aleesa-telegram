package Teapot::Bot::Object::ChatLocation;
# ABSTRACT: The base class for Telegram message 'ChatLocation' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ChatLocation::VERSION = '0.023';

has 'location';
has 'address';

sub fields {
  return {
    'Teapot::Bot::Object::Location' => [qw/location/],
    'scalar'                        => [qw/address/],
  };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::ChatLocation - The base class for Telegram message 'ChatLocation' type

=head1 VERSION

version 0.023

=head1 DESCRIPTION
The base class for Telegram message 'ChatLocation' type.

See L<https://core.telegram.org/bots/api#chatlocation> for details of the
attributes available for C<Teapot::Bot::Object::ChatLocation> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
