package Teapot::Bot::Object::ChatPermissions;
# ABSTRACT: The base class for Telegram 'ChatPermissions' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Carp qw(carp);
use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Brain ();

$Teapot::Bot::Object::ChatPermissions::VERSION = '0.025';

# all fields are optional
# N.B. Some of the fields "overlaps" other, so in order to guess valid set of permissions you should check all of them
has 'can_send_messages';         # True, if the user is allowed to send text messages, contacts, locations and venues
has 'can_send_media_messages';   # True, if the user is allowed to send audios, documents, photos, videos, video notes
                                 # and voice notes, implies can_send_messages
has 'can_send_polls';            # True, if the user is allowed to send polls, implies can_send_messages
has 'can_send_other_messages';   # True, if the user is allowed to send animations, games, stickers and use inline bots,
                                 # implies can_send_media_messages
has 'can_add_web_page_previews'; # True, if the user is allowed to add web page previews to their messages, implies
                                 # can_send_media_messages
has 'can_change_info';           # True, if the user is allowed to change the chat title, photo and other settings.
                                 # Ignored in public supergroups
has 'can_invite_users';          # True, if the user is allowed to invite new users to the chat
has 'can_pin_messages';          # True, if the user is allowed to pin messages. Ignored in public supergroups
has 'can_manage_topics';         # Optional. True, if the user is allowed to create forum topics. If omitted defaults to
                                # the value of can_pin_messages

sub fields {
  return {
          'scalar'                           => [qw/can_send_messages can_send_media_messages can_send_polls
                                                    can_send_other_messages can_add_web_page_previews can_change_info
                                                    can_invite_users can_pin_messages can_manage_topics/],
         };
}

sub canTalk {
  my $self;
  my $args = {};

  # There is some magic happen if we call function as object, as we usually do here
  # But if we access function from usual-style wrapper that calls it directly from namespace it supply noy $self object
  # but string with its name, which is a bummer.
  while (my $o = shift @_) {
    if (ref ($o) ne '') {
      $self = $o;
      last;
    }
  }

  my $chatid = shift;

  $args->{chat_id} = $chatid;
  my $can_talk = 0;
  my $ret;

  if (! defined($self->token) || $self->token eq '') {
    $ret->{error}   = 1;
    $ret->{message} = 'No token supplied to canTalk()';

    return $ret;
  }

  unless ($args->{chat_id}) {
    $ret->{error}   = 1;
    $ret->{message} = 'No chat_id supplied to canTalk()';

    return $ret;
  }

  if ($chatid < 0) {
    # group chat
    my $chatobj = Teapot::Bot::Brain->getChat ($args);

    # on api error, keep silence
    if ($chatobj == 0 || $chatobj->{error}) {
      my $emesg = "Unable to get chat info for $chatid from telegram API";
      $ret->{message}  = $emesg;
      $ret->{error}    = 1;
      $ret->{can_talk} = 0;
      return $ret;
    }

    my $myObj = Teapot::Bot::Brain->getMe ($self);

    # on api error, keep silence
    if ($myObj == 0 || $myObj->{error}) {
      my $emesg = "Unable to get chat info for $chatid from telegram API";
      $ret->{message}  = $emesg;
      $ret->{error}    = 1;
      $ret->{can_talk} = 0;

      return $ret;
    }

    my $myid = $myObj->id;
    $args->{user_id} = $myid;
    my $me = Teapot::Bot::Brain->getChatMember ($self, $args);

    # on api error, keep silence
    if ($me == 0 || $me->{error}) {
      my $emesg = 'Unable to get chat info for bot itself from telegram API';
      $ret->{message}  = $emesg;
      $ret->{error}    = 1;
      $ret->{can_talk} = 0;

      return $ret;
    }

    if ($me->{'status'} eq 'administrator') {
      $can_talk = 1;
    } else {
      my $group_talk = int ($chatobj->{permissions}->{can_send_messages});
      $can_talk = $group_talk;
    }
  } else {
    # 1 on 1 chat with user
    $can_talk = 1;
  }

  $ret->{error}    = 0;
  $ret->{can_talk} = $can_talk;

  return $ret;
}


1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::ChatPermissions - The base class for Telegram 'ChatPermissions' type objects

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram 'ChatPermissions' type objects.

See L<https://core.telegram.org/bots/api#chatpermissions> for details of the
attributes available for C<Teapot::Bot::Object::ChatPermissions> objects.

=head1 METHODS

=head2 canTalk

A convenience method to check if bot can talk in given conversation.

Returns hash reference with can_talk true if the bot can talk in given conversation, otherwise false.
Also set field error 1 if an error occurs during api interaction.
And if error set to true message field also set plus can_talk set to false.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
