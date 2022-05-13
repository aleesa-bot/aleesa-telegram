#!/usr/bin/perl
# По соглашению, рабочим каталогом является каталог с приложением, то есть запускать этот скрипт надо как
# util/get_chat_users_by_id.pl

# Для запуска этого скрипта нам понадобится список id пользователей и id чата, для которого мы дампим информацию о
# пользователях. Входные данные мы складываем в файл get_chat_users_by_id.json.

# На выходе в каталоге c->{cachedir} мы получим каталог get_chat_users_by_id/chat_id с кучей json-чиков, по одному на
# каждого пользователя.

use 5.018; ## no critic (ProhibitImplicitImport)
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );

use version; our $VERSION = qw (1.0);

my $workdir;

# before we run, change working dir
BEGIN {
	use Cwd qw (chdir abs_path);
	my @CWD = split /\//xms, abs_path ($PROGRAM_NAME);

	if ($#CWD > 1) {
		$#CWD = $#CWD - 2;
	}

	$workdir = join '/', @CWD;
	chdir $workdir;
}

use lib ("$workdir/lib", "$workdir/vendor_perl", "$workdir/vendor_perl/lib/perl5");
no Cwd;
use Cwd::utf8 qw (chdir abs_path);
use Data::Dumper qw (Dumper);
use File::Path qw(make_path);
use JSON::XS qw (decode_json);
# Грех не воспользоваться, если у нас оно есть под рукой, хотя по мне тут достаточно Http::Tiny
use Mojo::UserAgent ();

use BotLib::Conf qw (LoadConf);

# Поехали!
my $c = LoadConf ();

# Пример содержимого файлика: {"chatid": -номер, "users": ["id1", "id2"]}
my $data = LoadConf ("$workdir/get_chat_users_by_id.json");

unless (defined $c->{cachedir}) {
	die "Please define cachedir in data/config.jason\n";
}

unless (defined $data->{chatid}) {
	die "Please define chatid in get_chat_users_by_id.json\n";
}

my $targetDir = sprintf ("%s/get_chat_users_by_id/%s", $c->{cachedir}, $data->{chatid});

make_path ($targetDir) or die "Unable to create $targetDir: $OS_ERROR\n";

my $url = sprintf (
	"https://api.telegram.org/bot%s/getChatMember",
	$c->{telegrambot}->{token},
);

while (my $userid = pop @{$data->{users}}) {
	my $ua  = Mojo::UserAgent->new->connect_timeout (3);
	my $r = $ua->post ($url => form => {chat_id => $data->{chatid}, user_id => $userid} )->result;

	# Do not flood api with requests!
	sleep 1;

	unless ($r->is_success) {
		warn sprintf ("Unable to get info about user: http status %s\n%s\n", $r->{code}, $r->body);
		next;
	}

	my $j = eval { decode_json ($r->body) };

	if (defined $j) {
		my $jobj = JSON::XS->new ();
		$jobj = $jobj->pretty (1);
		$jobj = $jobj->canonical (1);
		my $json = $jobj->encode ($j);

		my $file = sprintf "%s/%s.json", $targetDir, $userid;

		open (my $FH, '>', $file) or do {
			warn "Unable to write to $file: $OS_ERROR\n";
			next;
		};

		print $FH $json . "\n";
		close $FH;
	} else {
		warn sprintf ("Telegram bot api returns corrupted json: %s,\n%s\n", $r->body, $@);
	}
}
