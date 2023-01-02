package Teapot::Bot::Object::Dice;
# ABSTRACT: The base class for Telegram message 'Dice' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::Dice::VERSION = '0.025';

has 'emoji';
has 'value';

sub fields {
  return { scalar => [qw/emoji value/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::Dice - The base class for Telegram message 'Dice' type

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram message 'Dice' type.

See L<https://core.telegram.org/bots/api#dice> for details of the
attributes available for C<Teapot::Bot::Object::dice> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
