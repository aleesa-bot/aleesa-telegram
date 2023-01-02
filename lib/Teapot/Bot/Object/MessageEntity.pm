package Teapot::Bot::Object::MessageEntity;
# ABSTRACT: The base class for Telegram 'MessageEntity' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::User ();

$Teapot::Bot::Object::MessageEntity::VERSION = '0.025';

has 'type';
has 'offset';
has 'length';
has 'url';      # Optional.
has 'user';     # Optional. Teapot::Bot::Object::User
has 'language'; # Optional. For “pre” only, the programming language of the entity text

sub fields {
  return {
           'scalar'                    => [qw/type offset length url language/],
           'Teapot::Bot::Object::User' => [qw/user/],
         };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::MessageEntity - The base class for Telegram 'MessageEntity' type objects

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram 'MessageEntity' type objects.

See L<https://core.telegram.org/bots/api#messageentity> for details of the
attributes available for C<Teapot::Bot::Object::MessageEntity> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
