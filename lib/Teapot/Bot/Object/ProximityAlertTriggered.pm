package Teapot::Bot::Object::ProximityAlertTriggered;
# ABSTRACT: The base class for Telegram message 'ProximityAlertTriggered' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ProximityAlertTriggered::VERSION = '0.025';

has 'traveler'; # User
has 'watcher'; # User
has 'distance';

sub fields {
  return {
    'Teapot::Bot::Object::User' => [qw/traveler watcher/],
    'scalar'                    => [qw/distance/],
  };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::ProximityAlertTriggered - The base class for Telegram message 'ProximityAlertTriggered' type

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram message 'ProximityAlertTriggered' type.

See L<https://core.telegram.org/bots/api#proximityalerttriggered> for details of the
attributes available for C<Teapot::Bot::Object::ProximityAlertTriggered> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
