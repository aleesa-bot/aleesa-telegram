package Teapot::Bot::Object::Location;
# ABSTRACT: The base class for Telegram message 'Location' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::Location::VERSION = '0.023';

has 'longitude';
has 'latitude';
has 'horizontal_accuracy';
has 'live_period';
has 'heading';
has 'proximity_alert_radius';

sub fields {
  return { scalar => [qw/longitude latitude horizontal_accuracy live_period heading proximity_alert_radius/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::Location - The base class for Telegram message 'Location' type

=head1 VERSION

version 0.023

=head1 DESCRIPTION
The base class for Telegram message 'Location' type.

See L<https://core.telegram.org/bots/api#location> for details of the
attributes available for C<Teapot::Bot::Object::Location> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
