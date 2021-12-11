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
our @EXPORT_OK = qw (redisListener);

sub parse_message {
	my $self = shift;
	my $m = shift;
	my $answer = $m;
	my $send_to = $answer->{from};

	$log->error (Dumper $self);

	return;
};

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
