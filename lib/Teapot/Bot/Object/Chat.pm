package Teapot::Bot::Object::Chat;
# ABSTRACT: The base class for Telegram 'Chat' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::ChatPhoto ();
use Teapot::Bot::Object::Message ();
use Teapot::Bot::Object::ChatPermissions ();
use Teapot::Bot::Object::ChatLocation ();

$Teapot::Bot::Object::Chat::VERSION = '0.025';

has 'id';
has 'type';
has 'title';                    # Optional.
has 'username';                 # Optional.
has 'first_name';               # Optional.
has 'last_name';                # Optional.
has 'is_forum';                 # Optional. True, if the supergroup chat is a forum (has topics enabled)
has 'photo';                    # Teapot::Bot::Object::ChatPhoto. Optional. Returned only in getChat.
has 'active_usernames';         # Optional. If non-empty, the list of all active chat usernames; for private chats,
                                # supergroups and channels. Returned only in getChat.
has 'emoji_status_custom_emoji_id'; # Optional. Custom emoji identifier of emoji status of the other party in a private
                                # chat. Returned only in getChat.
has 'bio';                      # Optional. Bio of the other party in a private chat. Returned only in getChat.
has 'has_private_forwards';     # Optional. True, if privacy settings of the other party in the private chat allows to
                                # use tg://user?id=<user_id> links only in chats with the user.
                                # Returned only in getChat.
has 'has_restricted_voice_and_video_messages'; # Optional. True, if the privacy settings of the other party restrict
                                               # sending voice and video note messages in the private chat.
                                               # Returned only in getChat.
has 'join_to_send_messages';    # Optional. True, if users need to join the supergroup before they can send messages.
                                # Returned only in getChat.
has 'join_by_request'           # Optional. True, if all users directly joining the supergroup need to be approved by
                                # supergroup administrators. Returned only in getChat.
has 'description';              # Optional. Returned only in getChat.
has 'invite_link';              # Optional. Returned only in getChat.
has 'pinned_message';           # Teapot::Bot::Object::Message
has 'permissions';              # Teapot::Bot::Object::ChatPermissions. Optional. Default chat member permissions, for
                                # groups and supergroups. Returned only in getChat.
has 'slow_mode_delay';          # Optional. Returned only in getChat.
has 'message_auto_delete_time'; # Optional. The time after which all messages sent to the chat will be automatically
                                # deleted; in seconds. Returned only in getChat.
has 'has_aggressive_anti_spam_enabled'; # Optional. True, if aggressive anti-spam checks are enabled in the supergroup.
                                        # The field is only available to chat administrators. Returned only in getChat.
has 'has_hidden_members';       # Optional. True, if non-administrators can only get the list of bots and administrators
                                # in the chat. Returned only in getChat.
has 'has_protected_content';    # Optional. True, if messages from the chat can't be forwarded to other chats.
                                # Returned only in getChat.
has 'sticker_set_name';         # Optional. Returned only in getChat.
has 'can_set_sticker_set';      # Optional. Returned only in getChat.
has 'linked_chat_id';           # Optional. greater than 32 bits, smaller than 52 bits
has 'location';                 # Optional. Returned only in getChat.

sub fields {
  return {
          'scalar'                               => [qw/id type title username first_name last_name is_forum 
                                                        emoji_status_custom_emoji_id bio
                                                        has_private_forwards has_restricted_voice_and_video_messages
                                                        join_to_send_messages join_by_request description invite_link
                                                        slow_mode_delay message_auto_delete_time
                                                        has_aggressive_anti_spam_enabled has_hidden_members
                                                        has_protected_content sticker_set_name can_set_sticker_set
                                                        linked_chat_id/],
          'Teapot::Bot::Object::ChatPhoto'       => [qw/photo/],
          'Teapot::Bot::Object::Message'         => [qw/pinned_message/],
          'Teapot::Bot::Object::ChatPermissions' => [qw/permissions/],
          'Teapot::Bot::Object::ChatLocation'    => [qw/location/],
        };
}

sub arrays {
  return qw/active_usernames/;
}

sub is_user {
  return shift->id > 0;
}


sub is_group {
  return shift->id < 0;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::Chat - The base class for Telegram 'Chat' type objects

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram 'Chat' type objects.

See L<https://core.telegram.org/bots/api#chat> for details of the
attributes available for C<Teapot::Bot::Object::Chat> objects.

=head1 METHODS

=head2 is_user

Returns true is this is a chat is a single user.

=head2 is_group

Returns true if this is a chat is a group.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
