package Teapot::Bot::Object::Animation;
# ABSTRACT: The base class for Telegram message 'Animation' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::PhotoSize ();

$Teapot::Bot::Object::Animation::VERSION = '0.022';

has 'file_id';
has 'file_unique_id';
has 'width';
has 'height';
has 'duration';
has 'thumb'; #PhotoSize
has 'file_name';
has 'mime_type';
has 'file_size';

sub fields {
  return { scalar                           => [qw/file_id file_unique_id width height duration file_name mime_type
                                                   file_size/],
           'Teapot::Bot::Object::PhotoSize' => [qw/thumb/],
         };
}


1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::Animation - The base class for Telegram message 'Animation' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'Animation' type.

See L<https://core.telegram.org/bots/api#animation> for details of the
attributes available for C<Teapot::Bot::Object::Animation> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
