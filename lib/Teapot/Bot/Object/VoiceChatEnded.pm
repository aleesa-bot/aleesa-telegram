package Teapot::Bot::Object::VoiceChatEnded;
# ABSTRACT: The base class for Telegram message 'VoiceChatEnded' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::VoiceChatEnded::VERSION = '0.022';

# This object represents a service message about a voice chat started in the chat. Currently holds no information.
has 'duration';

sub fields {
  return { scalar => [qw/duration/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::VoiceChatEnded - The base class for Telegram message 'VoiceChatEnded' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'VoiceChatEnded' type.

See L<https://core.telegram.org/bots/api#voicechatended> for details of the
attributes available for C<Teapot::Bot::Object::VoiceChatEnded> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2021 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
