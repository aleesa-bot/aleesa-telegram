package Teapot::Bot::Object::ForumTopicReopened;
# ABSTRACT: The base class for Telegram message 'ForumTopicReopened' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ForumTopicReopened::VERSION = '0.024';


sub fields {
  return { };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::ForumTopicReopened - The 	base class for Telegram message 'ForumTopicReopened' type

=head1 VERSION

version 0.024

=head1 DESCRIPTION
The base class for Telegram message 'ForumTopicReopened' type.

See L<https://core.telegram.org/bots/api#forumtopicreopened> for details of the
attributes available for C<Teapot::Bot::Object::ForumTopicReopened> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2022 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
