package Teapot::Bot::Object::MessageReactionCount;
# ABSTRACT: The base class for Telegram message 'Reaction' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

use Teapot::Bot::Object::MessageReaction ();

$Teapot::Bot::Object::MessageReactionCount::VERSION = '0.026';

has 'type';        # Type of the reaction
has 'total_count'; # Number of times the reaction was added

sub fields {
  return {
    'Teapot::Bot::Object::MessageReaction' => [qw/type/],
    'scalar'                               => [qw/total_count/],
  };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::MessageReactionCount - The base class for Telegram message 'Reaction' type

=head1 VERSION

version 0.026

=head1 DESCRIPTION
The base class for Telegram message 'Reaction' type.

See L<https://core.telegram.org/bots/api#reactiontype> for details of the
attributes available for C<Teapot::Bot::Object::MessageReactionCount> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2025 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
