package Teapot::Bot::Object::MessageReaction;
# ABSTRACT: The base class for Telegram message 'Reaction' type.

use strict;
use warnings;
use 5.018; ## no critic (ProhibitImplicitImport)
use utf8;

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::MessageReaction::VERSION = '0.026';

has 'type';            # Type of the reaction, always “emoji”
has 'emoji';           # Reaction emoji. Currently, it can be one of "👍", "👎", "❤", "🔥", "🥰", "👏", "😁", "🤔",
# "🤯", "😱", "🤬", "😢", "🎉", "🤩", "🤮", "💩", "🙏", "👌", "🕊", "🤡", "🥱", "🥴", "😍", "🐳", "❤‍🔥", "🌚", "🌭",
# "💯", "🤣", "⚡", "🍌", "🏆", "💔", "🤨", "😐", "🍓", "🍾", "💋", "🖕", "😈", "😴", "😭", "🤓", "👻", "👨‍💻", "👀",
# "🎃", "🙈", "😇", "😨", "🤝", "✍", "🤗", "🫡", "🎅", "🎄", "☃", "💅", "🤪", "🗿", "🆒", "💘", "🙉", "🦄", "😘",
# "💊", "🙊", "😎", "👾", "🤷‍♂", "🤷", "🤷‍♀", "😡"
has 'custom_emoji_id'; # Only for ReactionTypeCustomEmoji. Custom emoji identifier.
has 'total_count';     # Only for ReactionCount. Number of times the reaction was added.

sub fields {
  return {
    'scalar'                    => [qw/type emoji custom_emoji_id total_count/],
  };
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Teapot::Bot::Object::MessageReaction - The base class for Telegram message 'Reaction' type

=head1 VERSION

version 0.026

=head1 DESCRIPTION
The base class for Telegram message 'Reaction' type.

See L<https://core.telegram.org/bots/api#reactiontype> for details of the
attributes available for C<Teapot::Bot::Object::MessageReaction> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2025 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
