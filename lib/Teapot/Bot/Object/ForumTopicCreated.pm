package Teapot::Bot::Object::ForumTopicCreated;
# ABSTRACT: The base class for Telegram message 'ForumTopicCreated' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ForumTopicCreated::VERSION = '0.025';

has 'name';
has 'icon_color';
has 'icon_custom_emoji_id';

sub fields {
  return { scalar => [qw/name icon_color icon_custom_emoji_id/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::ForumTopicCreated - The 	base class for Telegram message 'ForumTopicCreated' type

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram message 'ForumTopicCreated' type.

See L<https://core.telegram.org/bots/api#forumtopiccreated> for details of the
attributes available for C<Teapot::Bot::Object::ForumTopicCreated> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2022 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
