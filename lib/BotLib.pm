package BotLib;
# store here utility functions that are not protocol-specified

use 5.018; ## no critic (ProhibitImplicitImport)
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );

use Clone qw (clone);
use Math::Random::Secure qw (irand);
use Data::Dumper qw (Dumper);

use BotLib::Conf qw (LoadConf);
use BotLib::Admin qw (@ForbiddenMessageTypes GetForbiddenTypes AddForbiddenType
                      DelForbiddenType ListForbidden FortuneToggle FortuneStatus
                      PluginToggle PluginStatus PluginEnabled ChanMsgToggle ChanMsgStatus
					  GreetMsgToggle GreetMsgStatus GoodbyeMsgToggle GoodbyeMsgStatus);
use BotLib::Util qw (trim);

use version; our $VERSION = qw (1.1);
use Exporter qw (import);
our @EXPORT_OK = qw (Command Highlight BotSleep IsCensored);

my $c = LoadConf ();
my $csign = $c->{telegrambot}->{csign};
my $redismsg->{from} = 'telegram';
$redismsg->{plugin}  = 'telegram';
$redismsg->{misc}->{answer} = 1;
$redismsg->{misc}->{csign} = $c->{telegrambot}->{csign};
$redismsg->{misc}->{msg_format} = 0;
$redismsg->{misc}->{fwd_cnt} = 1;

sub Command {
	my $self = shift;
	my $msg = shift;
	my $text = shift;
	my $chatid = shift;

	my $reply;
	my ($userid, $username, $fullname, $highlight, $visavi) = Highlight ($msg);
	my $rmsg = clone ($redismsg);
	$rmsg->{userid}  = 0 + $userid;
	$rmsg->{chatid}  = 0 + $chatid;

	if ($chatid >= 0) {
		$rmsg->{mode}    = 'private';
	} else {
		$rmsg->{mode}    = 'public';
	}

	my $cmd = substr $text, 1;

	# Проверка #1 на админское разрешение некоторых команд
	my @cmds = qw (tits boobs tities boobies сиси сисечки);

	while (my $check = pop @cmds) {
		if ($cmd eq $check) {
			unless (PluginEnabled $chatid, 'oboobs') {
				return;
			}
		}
	}

	# Проверка #2 на админское разрешение некоторых команд
	$#cmds = -1;
	@cmds = qw (butt booty ass попа попка);

	while (my $check = pop @cmds) {
		if ($cmd eq $check) {
			unless (PluginEnabled $chatid, 'obutts') {
				return;
			}
		}
	}

	# Полноценный поиск простой команды во входящем сообщении
	$#cmds = -1;
	@cmds = qw (ping пинг пинх pong понг понх coin монетка roll dice кости ver version версия хэлп halp kde кде lat
	            лат friday пятница proverb пословица fortune фортунка f ф anek анек анекдот buni cat кис drink праздник fox лис
	            frog лягушка horse лошадь лошадка monkeyuser owl сова сыч rabbit bunny кролик snail улитка tits boobs tities
	            boobies сиси сисечки butt booty ass попа попка xkcd dig копать fish fishing рыба рыбка рыбалка);

	my $bingo = 0;

	while (my $check = pop @cmds) {
		if ($cmd eq $check) {
			$bingo = 1;
			last;
		}
	}

	# Поиск "сложных" команд во входящем сообщении
	if (($cmd =~ /^w\s/u) || ($cmd =~ /^п\s/u) || ($cmd =~ /^weather\s/u) || ($cmd =~ /^погода\s/u) ||
	    ($cmd =~ /^погодка\s/u) || ($cmd =~ /^погадка\s/u) || ($cmd =~ /^karma\s/u) || ($cmd =~ /карма\s/u)) {
		$bingo = 1;
	}

	# Если команда найдена...
	if ($bingo) {
		$rmsg->{message} = $text;
		$self->log->debug ('[DEBUG] Sending message to redis ' . Dumper ($rmsg));

		# Для некоторых команд мы хотим получать форматированный вывод
		$#cmds = -1;
		@cmds = qw (fortune фортунка f ф anek анек анекдот buni cat кис fox лис frog лягушка horse лошадь
		            лошадка monkeyuser owl сова сыч rabbit bunny кролик snail улитка tits boobs tities boobies сиси сисечки
		            butt booty ass попа попка xkcd);

		while (my $check = pop @cmds) {
			if ($cmd eq $check) {
				$rmsg->{misc}->{msg_format} = 1;
				last;
			}
		}

		# Для других команд, хотим, чтобы было упоминание пользователя в ответе, чтобы подсветить его
		$#cmds = -1;
		@cmds = qw (dig копать fish fishing рыба рыбка рыбалка);

		while (my $check = pop @cmds) {
			if ($cmd eq $check) {
				$rmsg->{misc}->{msg_format} = 1;
				$rmsg->{misc}->{username} = $highlight;
				last;
			}
		}

		# Если соединения с редиской нету, ждём, пока оно появится. Своего рода костыль на всякий случай.
		{
			do {
				my $ready = eval { $main::RCONN->is_connected; };
				last if ($ready);
			} while (sleep 1);
		}

		my $pubsub = $main::REDIS->pubsub;

		$pubsub->json ($c->{'redis_router_channel'})->notify (
			$c->{'redis_router_channel'} => $rmsg,
		);
	# Если команда не найдена, но строка подозрительно напоминает команду help
	} elsif (substr ($text, 1) eq 'help'  ||  substr ($text, 1) eq 'помощь') {
		$reply = << "MYHELP";
```
${csign}help | ${csign}помощь             - список команд
${csign}anek | ${csign}анек | ${csign}анекдот    - рандомный анекдот с anekdot.ru
${csign}buni                       - рандомный стрип hapi buni
${csign}bunny | ${csign}rabbit | ${csign}кролик  - кролик
${csign}cat | ${csign}кис                 - кошечка
${csign}coin | ${csign}монетка            - подбросить монетку - орёл или решка?
${csign}dig | ${csign}копать              - заняться археологией
${csign}drink | ${csign}праздник          - какой сегодня праздник?
${csign}fish | ${csign}рыба | ${csign}рыбка      - порыбачить
${csign}fishing | ${csign}рыбалка         - порыбачить
${csign}f | ${csign}ф                     - рандомная фраза из сборника цитат fortune_mod
${csign}fortune | ${csign}фортунка        - рандомная фраза из сборника цитат fortune_mod
${csign}fox | ${csign}лис                 - лисичка
${csign}friday | ${csign}пятница          - а не пятница ли сегодня?
${csign}frog | ${csign}лягушка            - лягушка
${csign}horse | ${csign}лошадка           - лошадка
${csign}lat | ${csign}лат                 - сгенерить фразу из крылатых латинских выражений
${csign}monkeyuser                 - рандомный стрип MonkeyUser
${csign}owl | ${csign}сова | ${csign}сыч         - сова
${csign}proverb | ${csign}пословица       - рандомная русская пословица
${csign}ping | ${csign}пинг               - попинговать бота
${csign}roll | ${csign}dice | ${csign}кости      - бросить кости
${csign}snail | ${csign}улитка            - улитка
${csign}ver | ${csign}version | ${csign}версия   - что-то про версию ПО
${csign}w город | ${csign}п город         - погода в указанном городе
${csign}weather город              - погода в указанном городе
${csign}погода город               - погода в указанном городе
${csign}погодка город              - погода в указанном городе
${csign}погадка город              - погода в указанном городе
${csign}xkcd                       - рандомный стрип с сайта xkcd.ru
${csign}karma фраза | ${csign}карма фраза - посмотреть карму фразы
фраза-- | фраза++           - убавить или добавить карму фразе
```
Но на самом деле я бот больше для общения, чем для исполнения команд.
Поговоришь со мной?
MYHELP
		$msg->replyMd ($reply);
		return;
	# Если строка не найдена, но это команда admin
	} elsif (substr ($text, 1) eq 'admin'  ||  substr ($text, 1) eq 'админ') {
		my $member = $self->getChatMember ({ 'chat_id' => $msg->chat->id, 'user_id' => $msg->from->id });

		# Это должно показываться только админам чата
		if (($member->status eq 'administrator') || ($member->status eq 'creator')) {
			$reply = << "MYADMIN";
```
${csign}admin censor type # - где 1 - вкл, 0 - выкл цензуры для означенного типа сообщений
${csign}админ ценз тип #    - где 1 - вкл, 0 - выкл цензуры для означенного типа сообщений
${csign}admin censor        - показать список состояния типов сообщений
${csign}админ ценз          - показать список состояния типов сообщений
${csign}admin fortune #     - где 1 - вкл, 0 - выкл фортунку с утра
${csign}admin фортунка #    - где 1 - вкл, 0 - выкл фортунку с утра
${csign}admin fortune       - показываем ли с утра фортунку для чата
${csign}admin фортунка      - показываем ли с утра фортунку для чата
${csign}admin greet #       - где 1 - вкл, 0 - выкл приветствия новых участников чата
${csign}admin приветствие # - где 1 - вкл, 0 - выкл приветствия новых участников чата
${csign}admin greet         - приветствуем ли новых участников чата
${csign}admin приветствие   - приветствуем ли новых участников чата
${csign}admin oboobs #      - где 1 - вкл, 0 - выкл плагина oboobs
${csign}admin oboobs        - показываем ли сисечки по просьбе участников чата (команды ${csign}tits, ${csign}tities, ${csign}boobs, ${csign}boobies, ${csign}сиси, ${csign}сисечки)
${csign}admin obutts #      - где 1 - вкл, 0 - выкл плагина obutts
${csign}admin obutts        - показываем ли попки по просьбе участников чата (команды ${csign}ass, ${csign}butt, ${csign}booty, ${csign}попа, ${csign}попка)
${csign}admin chan_msg      - оставляем ли сообщения присланные от имени (других) каналов
${csign}admin chan_msg #    - где 1 - оставляем, 0 - удаляем
```
Типы сообщений:
audio voice photo video animation sticker dice game poll document
MYADMIN

			$msg->replyMd ($reply);
		}

		return;
	# Если строка не найдена, но это команда admin с параметрами
	} elsif ((substr ($text, 1, 5) eq 'admin'  ||  substr ($text, 1, 5) eq 'админ') && (length ($text) >= 8)) {
		my $member = $self->getChatMember ({ 'chat_id' => $msg->chat->id, 'user_id' => $msg->from->id });

		# Это должно показываться только админам чата
		if (($member->status eq 'administrator') || ($member->status eq 'creator')) {
			# Вынем субкоманду, это первый аргумент команды admin
			my $command = trim (substr $text, 7);
			$cmd = undef;
			my $args;
			($cmd, $args) = split /\s+/, $command, 2;

			# Субкоманды не нашлось, ну и какбэ досвидонья
			if ($cmd eq '') {
				return;
			# Субкоманда censor...
			} elsif ($cmd eq 'censor' || $cmd eq 'ценз') {
				# Censor с аргументами
				if (defined ($args) && ($args ne '')) {
					my ($msgType, $toggle) = split /\s/, $args, 2;

					if (defined $toggle) {
						foreach (@ForbiddenMessageTypes) {
							if ($msgType eq $_) {
								if ($toggle == 1) {
									AddForbiddenType ($chatid, $msgType);
									$reply = "Теперь сообщения с $msgType будут автоматически удаляться";
								} elsif ($toggle == 0) {
									DelForbiddenType ($chatid, $msgType);
									$reply = "Теперь сообщения с $msgType будут оставаться";
								}
							}
						}
					}
				# Censor без аргументов, выдаёт список типов сообщений и будут ли они автоматически удаляться
				} else {
					$reply = ListForbidden ($chatid);
				}
			# Хотим ли мы показывать фортунку с утра
			} elsif ($cmd eq 'fortune' || $cmd eq 'фортунка') {
				if (defined $args) {
					if ($args == 1) {
						$reply = FortuneToggle ($chatid, 1);
					} elsif ($args == 0) {
						$reply = FortuneToggle ($chatid, 0);
					}
				} else {
					$reply = FortuneStatus ($chatid);
				}
			# Хотим ли мы удалять "сообщения от каналов"
			} elsif ($cmd eq 'chan_msg') {
				if (defined $args) {
					if ($args == 1) {
						$reply = ChanMsgToggle ($chatid, 1);
					} elsif ($args == 0) {
						$reply = ChanMsgToggle ($chatid, 0);
					}
				} else {
					$reply = ChanMsgStatus ($chatid);
				}
			# Приветствуем ли мы новых участников чата
			} elsif ($cmd eq 'greet' || $cmd eq 'приветствие') {
				if (defined $args) {
					if ($args == 1) {
						$reply = GreetMsgToggle ($chatid, 1);
					} elsif ($args == 0) {
						$reply = GreetMsgToggle ($chatid, 0);
					}
				} else {
					$reply = GreetMsgStatus ($chatid);
				}
			} elsif ($cmd eq 'goodbye' || $cmd eq 'прощание') {
				if (defined $args) {
					if ($args == 1) {
						$reply = GoodbyeMsgToggle ($chatid, 1);
					} elsif ($args == 0) {
						$reply = GoodbyeMsgToggle ($chatid, 0);
					}
				} else {
					$reply = GoodbyeMsgStatus ($chatid);
				}
			# Работает ли плагин oboobs в чатике
			} elsif ($cmd eq 'oboobs') {
				if (defined $args) {
					if ($args == 1) {
						$reply = PluginToggle ($chatid, 'oboobs', 1);
					} elsif ($args == 0) {
						$reply = PluginToggle ($chatid, 'oboobs', 0);
					}
				} else {
					$reply = PluginStatus ($chatid, 'oboobs');
				}
			# Работает ли плагин obutts в чатике
			} elsif ($cmd eq 'obutts') {
				if (defined $args) {
					if ($args == 1) {
						$reply = PluginToggle ($chatid, 'obutts', 1);
					} elsif ($args == 0) {
						$reply = PluginToggle ($chatid, 'obutts', 0);
					}
				} else {
					$reply = PluginStatus ($chatid, 'obutts');
				}
			}
		}
	}

	return $reply;
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

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
