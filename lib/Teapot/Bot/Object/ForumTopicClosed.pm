package Teapot::Bot::Object::ForumTopicClosed;
# ABSTRACT: The base class for Telegram message 'ForumTopicClosed' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ForumTopicClosed::VERSION = '0.025';


sub fields {
  return { };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::ForumTopicClosed - The 	base class for Telegram message 'ForumTopicClosed' type

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram message 'ForumTopicClosed' type.

See L<https://core.telegram.org/bots/api#forumtopicclosed> for details of the
attributes available for C<Teapot::Bot::Object::ForumTopicClosed> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2022 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
