#!/usr/bin/perl
#
use strict;
use warnings;

my %chats;
open my $F, '<', 'debug.log' or die "Unable to open debug.log: $!\n"; ## no critic (ErrorHandling::RequireUseOfExceptions, InputOutput::RequireBriefOpen)

foreach my $line (<$F>) { ## no critic (InputOutput::ProhibitReadlineInForLoop)
	if ($line =~ /.DEBUG. In public chat .* \(\-(\d+)\) .* say:/) {
			next unless defined $1;
			next if $1 eq '';

			$chats{$1} = 1;
	}
}

close $F;

open $F, '>', 'chatlist.txt' or die "Unable to open chatlist.txt: $!\n"; ## no critic (ErrorHandling::RequireUseOfExceptions)

foreach my $chat (keys %chats) {
	print $F "$chat\n";
}

close $F;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
