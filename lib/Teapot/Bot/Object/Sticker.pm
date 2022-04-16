package Teapot::Bot::Object::Sticker;
# ABSTRACT: The base class for Telegram message 'Sticker' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::PhotoSize ();
use Teapot::Bot::Object::MaskPosition ();

$Teapot::Bot::Object::Sticker::VERSION = '0.023';

has 'file_id';
has 'file_unique_id';
has 'width';
has 'height';
has 'is_animated';
has 'is_video';
has 'thumb'; # PhotoSize
has 'emoji';
has 'set_name';
has 'mask_position';
has 'file_size';

sub fields {
  return {
           scalar                           => [ qw/file_id file_unique_id width height is_animated is_video emoji set_name file_size/ ],
           'Teapot::Bot::Object::PhotoSize' => [ qw/thumb/ ],
           'Teapot::Bot::Object::MaskPosition' => [qw/mask_position/],
         };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::Sticker - The base class for Telegram message 'Sticker' type

=head1 VERSION

version 0.023

=head1 DESCRIPTION
The base class for Telegram message 'Sticker' type.

See L<https://core.telegram.org/bots/api#sticker> for details of the
attributes available for C<Teapot::Bot::Object::Sticker> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
