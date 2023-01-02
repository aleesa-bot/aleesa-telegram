package Teapot::Bot::Object::VideoChatEnded;
# ABSTRACT: The base class for Telegram message 'VideoChatEnded' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::VideoChatEnded::VERSION = '0.025';

# This object represents a service message about a Video chat started in the chat. Currently holds no information.
has 'duration';

sub fields {
  return { scalar => [qw/duration/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::VideoChatEnded - The base class for Telegram message 'VideoChatEnded' type

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram message 'VideoChatEnded' type.

See L<https://core.telegram.org/bots/api#Videochatended> for details of the
attributes available for C<Teapot::Bot::Object::VideoChatEnded> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2022 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
