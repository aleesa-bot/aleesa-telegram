package Teapot::Bot::Object::PollAnswer;
# ABSTRACT: The base class for Telegram 'PollOption' type objects

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::PollAnswer::VERSION = '0.025';

has 'poll_id';
has 'user';
has 'option_ids';

sub fields {
  return {
    'scalar'                    => [qw/poll_id option_ids/],
    'Teapot::Bot::Object::User' => [qw/user/],
  };
}

sub arrays {
  return qw/option_ids/;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::PollAnswer - The base class for Telegram 'PollAnswer' type objects

=head1 VERSION

version 0.025

=head1 DESCRIPTION
The base class for Telegram 'PollAnswer' type objects.

See L<https://core.telegram.org/bots/api#pollanswer> for details of the
attributes available for C<Teapot::Bot::Object::PollAnswer> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2021 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
