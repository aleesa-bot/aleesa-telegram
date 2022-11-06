package Teapot::Bot::Object::VideoChatStarted;
# ABSTRACT: The base class for Telegram message 'VideoChatStarted' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::VideoChatStarted::VERSION = '0.024';

# This object represents a service message about a Video chat started in the chat. Currently holds no information.
has 'stub';

sub fields {
  return { scalar => [qw/stub/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::VideoChatStarted - The base class for Telegram message 'VideoChatStarted' type

=head1 VERSION

version 0.024

=head1 DESCRIPTION
The base class for Telegram message 'VideoChatStarted' type.

See L<https://core.telegram.org/bots/api#Videochatstarted> for details of the
attributes available for C<Teapot::Bot::Object::VideoChatStarted> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2022 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
