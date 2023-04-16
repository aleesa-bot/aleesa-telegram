package Teapot::Bot::Object::Venue;
# ABSTRACT: The base class for Telegram 'LoginUrl' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::Location ();

$Teapot::Bot::Object::Venue::VERSION = '0.026';

has 'location'; #Location
has 'title';
has 'address';
has 'foursquare_id';
has 'foursquare_type';
has 'google_place_id';
has 'google_place_type';

sub fields {
  return {
           'scalar'                        => [qw/title address foursquare_id foursquare_type google_place_id google_place_type/],
           'Teapot::Bot::Object::Location' => [qw/location/],
         };

}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::Venue - The base class for Telegram 'LoginUrl' type objects

=head1 VERSION

version 0.026

=head1 DESCRIPTION
The base class for Telegram 'LoginUrl' type objects.

See L<https://core.telegram.org/bots/api#venue> for details of the
attributes available for C<Teapot::Bot::Object::Venue> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
