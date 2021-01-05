package kitty;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Carp qw (cluck);
use JSON::XS;
use HTTP::Tiny;
use Math::Random::Secure qw (irand);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (kitty);

sub kitty {
	my $r;
	my $ret = 'Нету кошечек, все разбежались.';

	for (1..3) {
		my $http = HTTP::Tiny->new (timeout => 3);
		$r = $http->get ('https://api.thecatapi.com/v1/images/search');

		if ($r->{success}) {
			last;
		}

		sleep 2;
	}

	if ($r->{success}) {
		my $jcat = eval {
			decode_json ($r->{content})
		};

		if ($EVAL_ERROR) {
			cluck "[ERROR] Unable to decode JSON: $EVAL_ERROR";
		} else {
			if ($jcat->[0]->{url}) {
				my @cats = ('龴ↀ◡ↀ龴', '=^..^=', '≧◔◡◔≦ ','^ↀᴥↀ^' );
				$ret = sprintf '[%s](%s)', $cats[irand ($#cats + 1)], $jcat->[0]->{url};
			}
		}
	} else {
		cluck sprintf 'Server return status %s with message: %s', $r->{status}, $r->{reason};
	}

	return $ret;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
