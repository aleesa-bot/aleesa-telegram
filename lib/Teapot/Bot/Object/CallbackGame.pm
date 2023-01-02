package Teapot::Bot::Object::CallbackGame;
# ABSTRACT: The base class for Telegram message 'CallbackGame' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';
$Teapot::Bot::Object::CallbackGame::VERSION = '0.025';

# https://core.telegram.org/bots/api#callbackgame
# "A placeholder, currently holds no information. Use BotFather to set up your game"

sub fields {
  return { };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::CallbackGame - The base class for Telegram message 'CallbackGame' type

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram message 'CallbackGame' type.

See L<https://core.telegram.org/bots/api#callbackgame> for details of the
attributes available for C<Teapot::Bot::Object::CallbackGame> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
