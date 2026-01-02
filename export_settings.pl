#!/usr/bin/perl

# Плагин для сохранения настроек чатов. Экспортирует настройки в json, который можно использовать для импорта в другого
# бота.
#
# Файлик data/chatlist.txt придётся добывать грепаньем дебаг-логов (через скрипт extract_chatlist.txt.pl).
# Формат 1 chatid на строку.


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
		$#CWD = $#CWD - 1;
	}

	$workdir = join '/', @CWD;
	chdir $workdir;
}

use lib ("$workdir/lib", "$workdir/vendor_perl", "$workdir/vendor_perl/lib/perl5");
no Cwd;


use Data::Dumper qw(Dumper);
use JSON::XS ();

use BotLib::Admin qw(
	FortuneToggleList FortuneEnabled
	ChanMsgToggleList ChanMsgEnabled
	GreetMsgToggleList GreetMsgEnabled
	GoodbyeMsgToggleList GoodbyeMsgEnabled
	MuteByAdminToggleList MuteByAdminEnabled
	PluginEnabled);
use BotLib::Conf qw(LoadConf);

my $settings;

my $chatlistfile = 'data/chatlist.txt';

my $c = LoadConf('data/config.json');

my $admin_dir = $c->{admin}->{dir};
my $cachedir = $c->{cachedir};

# Достаём список чатов, где настроена fortune-ка по утрам.
my @fortune_chats = FortuneToggleList();

foreach my $chatid (@fortune_chats) {
	$settings->{$chatid}->{fortune} = FortuneEnabled($chatid);
}

# Достаём список чатов, где настроена возможность удаления сообщений, отправленных от имени другого калана.
my @chanmsg_chats = ChanMsgToggleList();

foreach my $chatid (@chanmsg_chats) {
	$settings->{$chatid}->{chanmsg} = ChanMsgEnabled($chatid);
}

# Достаём список чатов, где настроены приветственные сообщения.
my @greetmsg_chats = GreetMsgToggleList();

foreach my $chatid (@greetmsg_chats) {
	$settings->{$chatid}->{greetmsg} = GreetMsgEnabled($chatid);
}

# Достаём список чатов, где настроены прощальные сообщения.
my @goodbyemsg_chats = GoodbyeMsgToggleList();

foreach my $chatid (@goodbyemsg_chats) {
	$settings->{$chatid}->{goodbyemsg} = GoodbyeMsgEnabled($chatid);
}

# Достаём список чатов, где настроена возможность мута администратором.
my @adminmute_chats = MuteByAdminToggleList();

foreach my $chatid (@adminmute_chats) {
	$settings->{$chatid}->{adminmute} = MuteByAdminEnabled($chatid);
}

open my $F, '<', $chatlistfile or die "Unable to open $chatlistfile\n"; ## no critic (ErrorHandling::RequireUseOfExceptions,InputOutput::RequireBriefOpen)

foreach my $chatid (<$F>) { ## no critic (InputOutput::ProhibitReadlineInForLoop)
	chomp $chatid;
	next if $chatid eq '';

	if (PluginEnabled($chatid, 'oboobs')) {
		$settings->{$chatid}->{plugins}->{oboobs} = 1;
	}
	if (PluginEnabled($chatid, 'obutts')) {
		$settings->{$chatid}->{plugins}->{obutts} = 1;
	}
}

close $F;

my $data;

foreach my $chatid (keys %$settings) {
	my $item->{id} = $chatid;

	if ($settings->{$chatid}->{fortune}) {
		$item->{fortune} = 1;
	} else {
		$item->{fortune} = 0;
	}

	if ($settings->{$chatid}->{chanmsg}) {
		$item->{chanmsg} = 1;
	} else {
		$item->{chanmsg} = 0;
	}

	if ($settings->{$chatid}->{greetmsg}) {
		$item->{greetmsg} = 1;
	} else {
		$item->{greetmsg} = 0;
	}

	if ($settings->{$chatid}->{goodbyemsg}) {
		$item->{goodbyemsg} = 1;
	} else {
		$item->{goodbyemsg} = 0;
	}

	if ($settings->{$chatid}->{adminmute}) {
		$item->{adminmute} = 1;
	} else {
		$item->{adminmute} = 0;
	}

	if ($settings->{$chatid}->{plugins}->{obutts}) {
		$item->{plugins}->{obutts} = 1;
	} else {
		$item->{plugins}->{obutts} = 0;
	}

	if ($settings->{$chatid}->{plugins}->{oboobs}) {
		$item->{plugins}->{oboobs} = 1;
	} else {
		$item->{plugins}->{oboobs} = 0;
	}

	push @{$data}, $item;
}

my $json = eval { JSON::XS->new->utf8(1)->pretty(1)->encode($data) };

if (defined $json) {
	print $json . "\n";
} else {
	die "Unable to generate json, something went wrong: $EVAL_ERROR\n"; ## no critic (ErrorHandling::RequireUseOfExceptions)
}

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
