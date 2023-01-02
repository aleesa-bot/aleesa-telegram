package Teapot::Bot::Object::WebAppData;
# ABSTRACT: The base class for Telegram 'WebAppData' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::WebAppData::VERSION = '0.025';

has 'data';
has 'button_text';

sub fields {
  return { scalar  => [qw/data button_text/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::WebAppData - The base class for Telegram 'WebAppData' type objects

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram 'WebAppData' type objects.

See L<https://core.telegram.org/bots/api#webappdata> for details of the
attributes available for C<Teapot::Bot::Object::WebAppData> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2022 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
