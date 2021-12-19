package RedisLib;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use Log::Any qw ($log);
use Data::Dumper;

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (redis_parse_message);

sub redis_parse_message {
	my $self = shift;
	my $m = shift;

	$log->error (Dumper $self);

	# We cannot send message if we're not connected to telegram
	# TODO: Queue messages properly.

	until (defined $main::TGM) {
		sleep 1;
	}

	# TODO: add some checks, at least that the bot is not muted in chat
	$main::TGM->sendMessage (
		{
			chat_id => $m->{chatid},
			text => $m->{message}
		}
	);

	return;
};

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
