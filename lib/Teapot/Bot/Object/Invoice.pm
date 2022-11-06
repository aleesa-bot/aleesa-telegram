package Teapot::Bot::Object::Invoice;
# ABSTRACT: The base class for Telegram 'Invoice' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::Invoice::VERSION = '0.024';

has 'title';
has 'description';
has 'start_parameter';
has 'currency';
has 'total_amount';

sub fields {
  return { scalar => [qw/title description start_parameter currency total_amount/] };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::Invoice - The base class for Telegram 'Invoice' type objects

=head1 VERSION

version 0.024

=head1 DESCRIPTION
The base class for Telegram 'Invoice' type objects.

See L<https://core.telegram.org/bots/api#invoice> for details of the
attributes available for C<Teapot::Bot::Object::Invoice> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
