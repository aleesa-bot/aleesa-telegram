package Teapot::Bot::Object::GeneralForumTopicHidden;
# ABSTRACT: The base class for Telegram message 'GeneralForumTopicHidden' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::GeneralForumTopicHidden::VERSION = '0.026';


sub fields {
  return { };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::GeneralForumTopicHidden - The 	base class for Telegram message 'GeneralForumTopicHidden' type

=head1 VERSION

version 0.026

=head1 DESCRIPTION
The base class for Telegram message 'GeneralForumTopicHidden' type.

See L<https://core.telegram.org/bots/api#generalforumtopichidden> for details of the
attributes available for C<Teapot::Bot::Object::GeneralForumTopicHidden> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2023 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
