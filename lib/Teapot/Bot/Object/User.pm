package Teapot::Bot::Object::User;
# ABSTRACT: The base class for Telegram message 'User' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::User::VERSION = '0.022';

has 'id';
has 'is_bot';
has 'first_name';
has 'last_name';                  # optional
has 'username';                   # optional
has 'language_code';              # optional
has 'can_join_groups';            # optional, only for getMe() method
has 'can_read_all_group_messages';# optional, only for getMe() method
has 'supports_inline_queries';    # optional, only for getMe() method

sub fields {
  return {
           scalar => [qw/id is_bot first_name last_name username language_code can_join_groups
                         can_read_all_group_messages supports_inline_queries/],
         };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::User - The base class for Telegram message 'User' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'User' type.

See L<https://core.telegram.org/bots/api#user> for details of the
attributes available for C<Teapot::Bot::Object::User> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
