package Teapot::Bot::Object::LoginUrl;
# ABSTRACT: The base class for Telegram 'LoginUrl' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::LoginUrl::VERSION = '0.022';

has 'url';
has 'forward_text';
has 'bot_username';
has 'request_write_access';

sub fields {
  return { 'scalar' => [qw/url forward_text bot_username request_write_access/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::LoginUrl - The base class for Telegram 'LoginUrl' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'LoginUrl' type objects.

See L<https://core.telegram.org/bots/api#loginurl> for details of the
attributes available for C<Teapot::Bot::Object::LoginUrl> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
