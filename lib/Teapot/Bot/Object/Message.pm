package Teapot::Bot::Object::Message;
# ABSTRACT: The base class for the Telegram type "Message".

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

use Teapot::Bot::Object::User ();
use Teapot::Bot::Object::Chat ();
use Teapot::Bot::Object::ChatMember ();
use Teapot::Bot::Object::ChatPermissions ();
use Teapot::Bot::Object::MessageEntity ();
use Teapot::Bot::Object::Audio ();
use Teapot::Bot::Object::Document ();
use Teapot::Bot::Object::Animation ();
use Teapot::Bot::Object::Game ();
use Teapot::Bot::Object::PhotoSize ();
use Teapot::Bot::Object::Sticker ();
use Teapot::Bot::Object::Video ();
use Teapot::Bot::Object::Voice ();
use Teapot::Bot::Object::VideoNote ();
use Teapot::Bot::Object::Contact ();
use Teapot::Bot::Object::Location ();
use Teapot::Bot::Object::Poll ();
use Teapot::Bot::Object::Location ();
use Teapot::Bot::Object::PhotoSize ();
use Teapot::Bot::Object::Invoice ();
use Teapot::Bot::Object::Venue ();
use Teapot::Bot::Object::SuccessfulPayment ();
use Teapot::Bot::Object::WriteAccessAllowed ();
use Teapot::Bot::Object::PassportData ();
use Teapot::Bot::Object::ForumTopicCreated ();
use Teapot::Bot::Object::ForumTopicEdited ();
use Teapot::Bot::Object::ForumTopicClosed ();
use Teapot::Bot::Object::ForumTopicReopened ();
use Teapot::Bot::Object::GeneralForumTopicHidden ();
use Teapot::Bot::Object::GeneralForumTopicUnhidden ();
use Teapot::Bot::Object::InlineKeyboardMarkup ();
use Teapot::Bot::Object::ProximityAlertTriggered ();
use Teapot::Bot::Object::Dice ();
use Teapot::Bot::Object::MessageAutoDeleteTimerChanged ();
use Teapot::Bot::Object::VideoChatScheduled ();
use Teapot::Bot::Object::VideoChatStarted ();
use Teapot::Bot::Object::VideoChatEnded ();
use Teapot::Bot::Object::VideoChatParticipantsInvited ();

$Teapot::Bot::Object::Message::VERSION = '0.026';

# basic message stuff
has 'message_id';
has 'message_thread_id'; # Optional. Unique identifier of a message thread to which the message belongs;
                         # for supergroups only
has 'from';  # User
has 'sender_chat';  # Chat
has 'date';
has 'chat';  # Chat
has 'forward_from'; # User
has 'forward_from_chat'; # Chat
has 'forward_from_message_id';
has 'forward_signature';
has 'forward_sender_name';
has 'forward_date';
has 'is_topic_message'; # Optional. True, if the message is sent to a forum topic
has 'is_automatic_forward';
has 'reply_to_message'; # Message
has 'via_bot'; # User
has 'edit_date';
has 'has_protected_content';
has 'media_group_id';
has 'author_signature';
has 'text';
has 'entities'; # Array of MessageEntity
has 'animation'; # Animation
has 'audio'; # Audio
has 'document'; # Document
has 'photo'; # Array of PhotoSize
has 'sticker';  # Sticker
has 'video'; # Video
has 'video_note'; # VideoNote
has 'voice'; # Voice
has 'caption';
has 'caption_entities'; # Array of MessageEntity
has 'has_media_spoiler';
has 'contact'; # Contact
has 'dice';
has 'game';
has 'poll'; # Poll
has 'venue'; # Venue
has 'location'; # Location
has 'new_chat_members'; # Array of User
has 'left_chat_member'; # User
has 'new_chat_title';
has 'new_chat_photo'; # Array of PhotoSize
has 'delete_chat_photo';
has 'group_chat_created';
has 'supergroup_chat_created';
has 'channel_chat_created';
has 'message_auto_delete_timer_changed'; # Optional. Service message: auto-delete timer settings changed in the chat
has 'migrate_to_chat_id';
has 'migrate_from_chat_id';
has 'pinned_message'; # Message
has 'invoice'; # Invoice
has 'successful_payment'; # SuccessfulPayment
has 'connected_website';
has 'write_access_allowed'; # WriteAccessAllowed
has 'passport_data'; # PassportData
has 'proximity_alert_triggered';
has 'forum_topic_created'; # ForumTopicCreated
has 'forum_topic_edited'; # ForumTopicEdited
has 'forum_topic_closed'; # ForumTopicClosed
has 'forum_topic_reopened'; # ForumTopicReopened
has 'general_forum_topic_hidden'; # GeneralForumTopicHidden
has 'general_forum_topic_unhidden'; # GeneralForumTopicUnhidden
has 'video_chat_scheduled';
has 'video_chat_started';
has 'video_chat_ended';
has 'video_chat_participants_invited';
has 'web_app_data';
has 'reply_markup'; # Array of InlineKeyboardMarkup

sub fields {
  return {
          'scalar'                                         => [qw/message_id message_thread_id date forward_from_message_id
                                                               forward_signature forward_sender_name forward_date
                                                               is_topic_message is_automatic_forward edit_date
                                                               has_protected_content media_group_id author_signature text
                                                               caption has_media_spoiler new_chat_title delete_chat_photo
                                                               group_chat_created supergroup_chat_created
                                                               channel_chat_created migrate_to_chat_id
                                                               migrate_from_chat_id connected_website/],
          'Teapot::Bot::Object::User'                      => [qw/from forward_from via_bot new_chat_members left_chat_member /],

          'Teapot::Bot::Object::Chat'                      => [qw/sender_chat chat forward_from_chat/],
          'Teapot::Bot::Object::Message'                   => [qw/reply_to_message pinned_message/],
          'Teapot::Bot::Object::MessageEntity'             => [qw/entities caption_entities /],

          'Teapot::Bot::Object::Audio'                     => [qw/audio/],
          'Teapot::Bot::Object::Document'                  => [qw/document/],
          'Teapot::Bot::Object::Animation'                 => [qw/animation/],
          'Teapot::Bot::Object::Game'                      => [qw/game/],
          'Teapot::Bot::Object::PhotoSize'                 => [qw/photo new_chat_photo/],
          'Teapot::Bot::Object::Sticker'                   => [qw/sticker/],
          'Teapot::Bot::Object::Video'                     => [qw/video/],
          'Teapot::Bot::Object::Voice'                     => [qw/voice/],
          'Teapot::Bot::Object::VideoNote'                 => [qw/video_note/],

          'Teapot::Bot::Object::Contact'                   => [qw/contact/],
          'Teapot::Bot::Object::Location'                  => [qw/location/],
          'Teapot::Bot::Object::Venue'                     => [qw/venue/],

          'Teapot::Bot::Object::Poll'                      => [qw/poll/],

          'Teapot::Bot::Object::Invoice'                   => [qw/invoice/],
          'Teapot::Bot::Object::SuccessfulPayment'         => [qw/successful_payment/],
          'Teapot::Bot::Object::WriteAccessAllowed'        => [qw/write_access_allowed/],
          'Teapot::Bot::Object::PassportData'              => [qw/passport_data/],
          'Teapot::Bot::Object::ForumTopicCreated'         => [qw/forum_topic_created/],
          'Teapot::Bot::Object::ForumTopicEdited'          => [qw/forum_topic_edited/],
          'Teapot::Bot::Object::ForumTopicClosed'          => [qw/forum_topic_closed/],
          'Teapot::Bot::Object::ForumTopicReopened'        => [qw/forum_topic_reopened/],
          'Teapot::Bot::Object::GeneralForumTopicHidden'   => [qw/general_forum_topic_unhidden/],
          'Teapot::Bot::Object::GeneralForumTopicUnhidden' => [qw/general_forum_topic_unhidden/],
          'Teapot::Bot::Object::InlineKeyboardMarkup'      => [qw/reply_markup/],
          'Teapot::Bot::Object::ProximityAlertTriggered'   => [qw/proximity_alert_triggered/],
          'Teapot::Bot::Object::Dice'                      => [qw/dice/],
          'Teapot::Bot::Object::MessageAutoDeleteTimerChanged' => [qw/message_auto_delete_timer_changed/],
          'Teapot::Bot::Object::VideoChatScheduled'        => [qw/video_chat_scheduled/],
          'Teapot::Bot::Object::VideoChatStarted'          => [qw/video_chat_started/],
          'Teapot::Bot::Object::VideoChatEnded'            => [qw/video_chat_ended/],
          'Teapot::Bot::Object::VideoChatParticipantsInvited' => [qw/video_chat_participants_invited/],
          'Teapot::Bot::Object::WebAppData'                => [qw/web_app_data/],
  };
}

sub arrays {
  return qw/photo entities caption_entities new_chat_members new_chat_photo/;
}

sub reply {
  my $self = shift;
  my $text = shift;

  my $ret = '';

  my $send_args->{chat_id} = $self->chat->id;
  my $message_thread_id   = eval {$self->message_thread_id};

  my $can_talk = $self->_brain->can_talk($send_args);

  if ($can_talk->{error}) {
    $ret = $can_talk;
  } else {
    if ($can_talk->{can_talk}) {
      $send_args->{text} = $text;

      if (defined $message_thread_id && $message_thread_id ne '') {
        $send_args->{$message_thread_id} = $message_thread_id;
      }

      $ret = $self->_brain->sendMessage($send_args);
    }
  }

  return $ret;
}

sub replyMd {
  my $self = shift;
  my $text = shift;

  my $ret = '';

  my $send_args->{chat_id} = $self->chat->id;
  my $message_thread_id    = eval {$self->message_thread_id};

  my $can_talk = $self->_brain->can_talk($send_args);

  if ($can_talk->{error}) {
    $ret = $can_talk;
  } else {
    if ($can_talk->{can_talk}) {
      $send_args->{text}              = $text;
      $send_args->{parse_mode}        = 'Markdown';
      $send_args->{message_thread_id} = $message_thread_id if (defined $message_thread_id);

      $ret                            = $self->_brain->sendMessage($send_args);
    }
  }

  return $ret;
}

sub typing {
  my $self = shift;

  my $ret                  = '';
  my $send_args->{chat_id} = $self->chat->id;
  my $can_talk             = $self->_brain->can_talk($send_args);

  if ($can_talk->{error}) {
    $ret = $can_talk;
  } else {
    if ($can_talk->{can_talk}) {
      $ret = $self->_brain->sendChatAction($send_args);
    }
  }

  return $ret;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::Message - The base class for the Telegram type "Message"

=head1 VERSION

version 0.026

=head1 DESCRIPTION
The base class for the Telegram type "Message".

See L<https://core.telegram.org/bots/api#message> for details of the
attributes available for C<Teapot::Bot::Object::Message> objects.

=head1 METHODS

=head2 reply

A convenience method to reply to a message with text.

Will return the C<Teapot::Bot::Object::Message> object representing the message
sent.
On error returns hash reference with error field set to 1, also set fields
param, url and debug (which is result of Mojo::UserAgent->post->result->json)


=head2 replyMd

A convenience method to reply to a message with markdown formatted text.

Will return the C<Teapot::Bot::Object::Message> object representing the message
sent.
On error returns hash reference with error field set to 1, also set fields
param, url and debug (which is result of Mojo::UserAgent->post->result->json)

=head2 typing

Sends notification to chat that bot is "typing" something.

On error returns hash reference with error field set to 1, also set fields
param, url and debug (which is result of Mojo::UserAgent->post->result->json)

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
