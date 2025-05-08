package Teapot::Bot::Object::MessageReactionUpdated;
# ABSTRACT: The base class for Telegram message 'ReactionUpdated' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

use Teapot::Bot::Object::Chat ();
use Teapot::Bot::Object::Chat ();
use Teapot::Bot::Object::User ();

$Teapot::Bot::Object::MessageReactionUpdated::VERSION = '0.026';

has 'chat';         # The chat containing the message the user reacted to
has 'message_id';   # Unique identifier of the message inside the chat
has 'user';         # Optional. The user that changed the reaction, if the user isn't anonymous
has 'actor_chat';   # Optional. The chat on behalf of which the reaction was changed, if the user is anonymous
has 'date';         # Date of the change in Unix time
has 'old_reaction'; # Previous list of reaction types that were set by the user
has 'new_reaction'; # New list of reaction types that have been set by the user

sub fields {
  return {
    'Teapot::Bot::Object::Chat'            => [qw/chat actor_chat/],
    'Teapot::Bot::Object::User'            => [qw/user/],
    'Teapot::Bot::Object::MessageReaction' => [qw/old_reaction new_reaction/],
    'scalar'                               => [qw/message_id date/],
  };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::MessageReaction - The base class for Telegram message 'ReactionUpdated' type

=head1 VERSION

version 0.026

=head1 DESCRIPTION
The base class for Telegram message 'ReactionUpdated' type.

See L<https://core.telegram.org/bots/api#messagereactionupdated> for details of the
attributes available for C<Teapot::Bot::Object::MessageReactionUpdated> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2025 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
