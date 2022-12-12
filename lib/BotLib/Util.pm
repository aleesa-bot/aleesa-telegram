package BotLib::Util;

use 5.018; ## no critic (ProhibitImplicitImport)
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Digest::SHA qw (sha1_base64);
use Encode qw (encode_utf8);
use Math::Random::Secure qw (irand);
use MIME::Base64 qw (encode_base64);
use Text::Fuzzy qw (distance_edits);
use URI::URL qw (url);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (trim urlencode fmatch utf2b64 utf2sha1 BotSleep Highlight IsCensored RandomCommonPhrase);

sub trim {
	my $str = shift;

	if ($str eq '') {
		return $str;
	}

	$str =~ s/^\s+//;
	$str =~ s/\s+$//;

	return $str;
}

sub urlencode {
	my $str = shift;
	my $urlobj = url $str;
	return $urlobj->as_string;
}

sub fmatch {
	my $srcphrase = shift;
	my $answer = shift;

	my ($distance, undef) = distance_edits ($srcphrase, $answer);
	my $srcphraselen = length $srcphrase;
	my $distance_max = int ($srcphraselen - ($srcphraselen * (100 - (90 / ($srcphraselen ** 0.5))) * 0.01));

	if ($distance >= $distance_max) {
		return 0;
	} else {
		return 1;
	}
}

sub utf2b64 {
	my $string = shift;

	if ($string eq '') {
		return encode_base64 '';
	}

	my $bytes = encode_utf8 $string;
	return encode_base64 $bytes;
}

sub utf2sha1 {
	my $string = shift;

	if ($string eq '') {
		return sha1_base64 '';
	}

	my $bytes = encode_utf8 $string;
	return sha1_base64 $bytes;
}

sub Highlight {
	my $msg = shift;

	my $fullname;
	my $highlight;
	my $username;
	my $visavi = '';
	my $userid = $msg->from->id;

	if ($msg->from->can ('username') && defined $msg->from->username ) {
		$username = $msg->from->username;
	}

	if ($msg->from->can ('first_name') && defined $msg->from->first_name) {
		$fullname = $msg->from->first_name;

		if ($msg->from->can ('last_name') && defined $msg->from->last_name) {
			$fullname .= ' ' . $msg->from->last_name;
		}
	} elsif ($msg->from->can ('last_name') && defined $msg->from->last_name) {
		$fullname .= $msg->from->last_name;
	}

	if (defined $username) {
		$visavi .= '@' . $username;

		if (defined $fullname) {
			$highlight = "[$fullname](tg://user?id=$userid)";
			$visavi .= ', ' . $fullname;
		} else {
			$highlight = "[$username](tg://user?id=$userid)";
		}
	} else {
		$highlight = "[$fullname](tg://user?id=$userid)";
		$visavi .= $fullname;
	}

	$visavi .= " ($userid)";

	return ($userid, $username, $fullname, $highlight, $visavi);
}

sub IsCensored {
	my $msg = shift;

	my $forbidden = GetForbiddenTypes ($msg->chat->id);

	# voice messages are special
	if (defined ($msg->voice) && defined ($msg->voice->duration) && ($msg->voice->duration > 0)) {
		if ($forbidden->{'voice'}) {
			return 1;
		}
	}

	foreach (keys %{$forbidden}) {
		if ($forbidden->{$_} && (defined $msg->{$_})) {
			return 1;
		}
	}

	return 0;
}

sub RandomCommonPhrase {
	my @myphrase = (
		'Так, блядь...',
		'*Закатывает рукава* И ради этого ты меня позвал?',
		'Ну чего ты начинаешь, нормально же общались',
		'Повтори свой вопрос, не поняла',
		'Выйди и зайди нормально',
		'Я подумаю',
		'Даже не знаю, что на это ответить',
		'Ты упал такие вопросы девочке задавать?',
		'Можно и так, но не уверена',
		'А как ты думаешь?',
		'А ви, таки, почему интересуетесь?',
	);

	return $myphrase[irand ($#myphrase + 1)];
}

sub BotSleep {
	# TODO: Parametrise this with fuzzy sleep time in seconds
	my $msg = shift;
	# let's emulate real human and delay answer
	sleep (irand (2) + 1);

	for (0..(4 + irand (3))) {
		$msg->typing ();
		sleep 3;
		sleep 3 unless ($_);
	}

	sleep ( 3 + irand (2));
	return;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
