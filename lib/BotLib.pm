package BotLib;
# store here utility functions that are not protocol-specified

use 5.018; ## no critic (ProhibitImplicitImport)
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );

use Clone qw (clone);
use Data::Dumper qw (Dumper);
use Log::Any qw ($log);
use Math::Random::Secure qw (irand);

use BotLib::Conf qw (LoadConf);
use BotLib::Admin qw (@ForbiddenMessageTypes GetForbiddenTypes AddForbiddenType
                      DelForbiddenType ListForbidden FortuneToggle FortuneStatus
                      PluginToggle PluginStatus PluginEnabled ChanMsgToggle ChanMsgStatus
                      GreetMsgToggle GreetMsgStatus GoodbyeMsgToggle GoodbyeMsgStatus MuteByAdminToggle
                      MuteByAdminStatus MuteByAdminEnabled);
use BotLib::Util qw (trim Highlight);

use version; our $VERSION = qw (1.1);
use Exporter qw (import);
our @EXPORT_OK = qw (Command);

my $c = LoadConf ();
my $csign = $c->{telegrambot}->{csign};

my $redismsg->{from}              = 'telegram';
$redismsg->{threadid}             = '';
$redismsg->{plugin}               = 'telegram';
$redismsg->{misc}->{answer}       = 1;
$redismsg->{misc}->{csign}        = "$c->{telegrambot}->{csign}";
$redismsg->{misc}->{msg_format}   = 0;
$redismsg->{misc}->{fwd_cnt}      = 1;
$redismsg->{misc}->{good_morning} = 0;

sub Command {
	my $self   = shift;
	my $msg    = shift;
	my $text   = shift;
	my $chatid = shift;

	my $reply;
	my ($userid, $username, $fullname, $highlight, $visavi) = Highlight ($msg);

	my $rmsg                = clone ($redismsg);
	$rmsg->{userid}         = "$userid";
	$rmsg->{chatid}         = "$chatid";
	$rmsg->{misc}->{answer} = 1;

	if ($chatid >= 0) {
		$rmsg->{mode}    = 'private';
	} else {
		$rmsg->{mode}    = 'public';
	}

	my $cmd = substr $text, length ($csign);

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
	            лат friday пятница proverb пословица fortune фортунка f ф anek анек анекдот buni cat кис drink праздник
	            fox лис frog лягушка horse лошадь лошадка monkeyuser owl сова сыч rabbit bunny кролик snail улитка tits
	            boobs tities boobies сиси сисечки butt booty ass попа попка xkcd dig копать fish fishing рыба рыбка
	            рыбалка karma карма fuck);

	my $bingo = 0;

	while (my $check = pop @cmds) {
		if ($cmd eq $check) {
			$bingo = 1;
			last;
		}
	}

	# Поиск "сложных" команд во входящем сообщении
	if ($cmd =~ /^(w|п|weather|погода|погодка|погадка|karma|карма)\s+/) { ## no critic (RegularExpressions::ProhibitComplexRegexes)
		$bingo = 1;
	}

	# Если команда найдена...
	if ($bingo) {
		$rmsg->{message} = "$text";

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
				$rmsg->{misc}->{username} = "$highlight";
				last;
			}
		}

		# Если тип группы supergroup, в ней могут быть треды, попробуем найти message_thread_id, если таковой есть
		if ($msg->chat->type eq 'supergroup') {
			if ($msg->can ('is_topic_message') && $msg->is_topic_message) {
				if ($msg->can ('message_thread_id') && $msg->message_thread_id ne '') {
					$rmsg->{threadid} = "$msg->message_thread_id";
				}
			}
		}

		# Если соединения с редиской нету, ждём, пока оно появится. Своего рода костыль на всякий случай.
		{
			do {
				my $ready = eval { $main::RCONN->is_connected; };
				last if ($ready);
			} while (sleep 1);
		}

		$log->debug ('[DEBUG] Outgoing redis message: ' . Dumper ($rmsg));

		my $pubsub = $main::REDIS->pubsub;

		$pubsub->json ($c->{'redis_router_channel'})->notify (
			$c->{'redis_router_channel'} => $rmsg,
		);
	# Если команда не найдена, но строка подозрительно напоминает команду help
	} elsif ($cmd =~ /^(help|помощь)$/u) {
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
		my $res = $msg->replyMd ("$reply");

		if ($res->{error}) {
			$log->error ('[ERROR] Unable to call sendMessage BotAPI method: ' . Dumper ($res));
		}

		return;
	# Если команда не найдена, но это команда admin :)
	} elsif ($cmd =~ /^(admin|админ)(\s+|\s+.*)?$/u) {
		my $send_args->{chat_id} = 0 + $chatid;
		$send_args->{user_id}    = 0 + $msg->from->id;
		my $member               = $self->getChatMember ($send_args);

		if ($member->{error}) {
			$log->error ('[ERROR] Unable to call getChatMember BotAPI method: ' . Dumper ($member));
			return;
		}

		# Это должно показываться только админам чата
		if (($member->status ne 'administrator') && ($member->status ne 'creator')) {
			$log->debug ("[DEBUG] Non admin member called ${csign}admin command, " . $member->status);
			return;
		}

		if ($cmd =~ /^(admin|админ)\s*$/u) {
			$reply = << "MYADMIN";
```
${csign}admin censor type #   - где 1 - вкл, 0 - выкл цензуры для означенного типа сообщений
${csign}админ ценз тип #      - где 1 - вкл, 0 - выкл цензуры для означенного типа сообщений
${csign}admin censor          - показать список состояния типов сообщений
${csign}админ ценз            - показать список состояния типов сообщений
${csign}admin fortune #       - где 1 - вкл, 0 - выкл фортунку с утра
${csign}admin фортунка #      - где 1 - вкл, 0 - выкл фортунку с утра
${csign}admin fortune         - показываем ли с утра фортунку для чата
${csign}admin фортунка        - показываем ли с утра фортунку для чата
${csign}admin greet #         - где 1 - вкл, 0 - выкл приветствия новых участников чата
${csign}admin приветствие #   - где 1 - вкл, 0 - выкл приветствия новых участников чата
${csign}admin greet           - приветствуем ли новых участников чата
${csign}admin приветствие     - приветствуем ли новых участников чата
${csign}admin oboobs #        - где 1 - вкл, 0 - выкл плагина oboobs
${csign}admin oboobs          - показываем ли сисечки по просьбе участников чата (команды ${csign}tits, ${csign}tities, ${csign}boobs, ${csign}boobies, ${csign}сиси, ${csign}сисечки)
${csign}admin obutts #        - где 1 - вкл, 0 - выкл плагина obutts
${csign}admin obutts          - показываем ли попки по просьбе участников чата (команды ${csign}ass, ${csign}butt, ${csign}booty, ${csign}попа, ${csign}попка)
${csign}admin chan_msg        - оставляем ли сообщения присланные от имени (других) каналов
${csign}admin chan_msg #      - где 1 - оставляем, 0 - удаляем
${csign}admin ban userid sec  - выдаём ban указанному user-у на указанное количество секунд (от 30 сек до 1 года), доступно только создателю чата
${csign}admin mute userid sec - выдаём mute указанному user-у на указанное количество секунд (от 30 сек до 1 года), доступно только создателю чата
${csign}admin admin mute      - разрешено ли обычным админам мьютить участников чата через бота (если бот - админ), (создатель чата всегда может попросить бота-админа замьютить обычного участника чата)
${csign}admin admin mute #    - где 1 - разрешено, 0 - не разрешено
```
Типы сообщений:
audio voice photo video animation sticker dice game poll document
MYADMIN

			my $res = $msg->replyMd ($reply);

			if ($res->{error}) {
				$log->error('[ERROR] Unable to call sendMessage BotAPI method: ' . Dumper($res));
			}

			return;
		} elsif ($cmd =~ /^admin\s+(admin\s+mute)(\s*|\s+0|\s+1)$/gu) {
			my $arg;
			$arg = trim $2 if (defined $2);

			if (defined $arg && $arg !~ /^\s*$/ && ($member->status eq 'creator')) {
				if ($arg == 1) {
					$reply = MuteByAdminToggle ($chatid, 1);
				} elsif ($arg == 0) {
					$reply = MuteByAdminToggle ($chatid, 0);
				}
			} else {
				$reply = MuteByAdminStatus ($chatid);
			}
		} elsif ($cmd =~ /^(admin|админ)\s+(ban|mute)\s+(\d+)\s+(\d+)$/gu) {
			if ($member->status eq 'admin' && (! MuteByAdminEnabled ($chatid))) {
				return 'Не буду я для тебя никого мьтить.';
			}

			my (undef, $action, $user_id_to_prosecute, $time) = split /\s+/, $cmd;

			# Бот должен быть админом, чтобы банить юзеров
			my $me = $self->getMe ();

			if ($me->{error}) {
				$log->error ('[ERROR] Unable to call getMe BotAPI method: ' . Dumper ($member));
				return;
			}

			my $myId = $me->id;

			if ($myId == $user_id_to_prosecute) {
				if ($action eq 'mute') {
					$reply = 'Я не буду себя мьютить.';
				} else {
					$reply = 'Я не буду себя банить.';
				}
			} else {
				$send_args = undef;
				$send_args->{chat_id} = 0 + $chatid;
				$send_args->{user_id} = 0 + $me->id;
				$me                   = $self->getChatMember ($send_args);

				if ($me->{error}) {
					$log->error ('[ERROR] Unable to call getChatMember BotAPI method: ' . Dumper ($me));
					return;
				}

				if ($me->status eq 'administrator') {
					# Проверим, что такой юзер есть в чятике
					$send_args = undef;
					$send_args->{chat_id} = 0 + $chatid;
					$send_args->{user_id} = 0 + $user_id_to_prosecute;
					my $chatMember        = $self->getChatMember ($send_args);

					if ($chatMember->{error}) {
						$log->error ('[ERROR] Unable to call getChatMember BotAPI method: ' . Dumper ($chatMember));
						return;
					}

					# Предположительно, юзер нашёлся
					my $memberStatus = $chatMember->status;

					if ($memberStatus eq 'creator') {
						if ($action eq 'mute') {
							$reply = 'Ты поехал себя мьютить?';
						} else {
							$reply = 'Ты поехал себя банить?';
						}
					} elsif ($memberStatus eq 'administrator') {
						if ($action eq 'mute') {
							$reply = 'Админов мьютить не буду.';
						} else {
							$reply = 'Админов банить не буду.';
						}
					} else {
						if ($time < 30) {
							$reply = 'Ты слишком добр.';
						} elsif ($time > (60 * 60 * 24 * 366)) {
							if ($action eq 'mute') {
								$reply = 'Мьют более чем на 366 дней - перманентный, ты слишком жесток, я так не играю.';
							} else {
								$reply = 'Бан более чем на 366 дней - перманентный, ты слишком жесток, я так не играю.';
							}
						} else {
							my $result;
							$send_args = undef;
							$send_args->{chat_id}    = 0 + $chatid;
							$send_args->{user_id}    = 0 + $user_id_to_prosecute;
							$send_args->{until_date} = $time + time ();

							if ($action eq 'mute') {
								$result = $self->muteChatMember ($send_args);
							} else {
								$result = $self->banChatMember ($send_args);
							}

							# Если всё хорошо, то возвращается true в формате JSON::PP::Boolean
							if ((ref ($result) eq 'JSON::PP::Boolean') && ($result == JSON::PP::true)) {
								$reply = 'Готово.';
							} elsif (defined ($result->{error}) && $result->{error}) {
								if ($action eq 'mute') {
									$log->error (
										'[ERROR] Unable to call muteChatMember BotAPI method: ' .
										Dumper ($result)
									);
									$reply = 'Что-то пошло не так, не получается замьютить.';
								} else {
									$log->error (
										'[ERROR] Unable to call banChatMember BotAPI method: ' .
											Dumper ($result)
									);
									$reply = 'Что-то пошло не так, не получается забанить.';
								}
							} else {
								$log->error (
									'[ERROR] Unable to call banChatMember/muteChatMember BotAPI method: ' .
										Dumper ($result)
								);
								$reply = 'Что-то пошло совсем не так.';
							}
						}
					}
				} else {
					$reply = 'Я так пока не умею, я здесь не админ.'
				}
			}
		} elsif ($cmd =~ /^admin\s+(censor|ценз)\s*$/gu) {
			$reply = ListForbidden ($chatid);
		} elsif ($cmd =~ /^admin\s+(censor|ценз)\s+(type|тип)\s+(.+)$/gu) {
			my $arg;
			$arg = trim $3 if (defined $3);

			if (defined $arg && $arg ne '') {
				my ($msgType, $toggle) = split /\s/, $arg, 2;

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
			}
		} elsif ($cmd =~ /^admin\s+(fortune|фортунка)(\s*|\s+0|\s+1)$/gu) {
			my $arg;
			$arg = trim $2 if (defined $2);

			if (defined $arg && $arg !~ /^\s*$/) {
				if ($arg == 1) {
					$reply = FortuneToggle ($chatid, 1);
				} elsif ($arg == 0) {
					$reply = FortuneToggle ($chatid, 0);
				}
			} else {
				$reply = FortuneStatus ($chatid);
			}
		} elsif ($cmd =~ /^admin\s+chan_msg(\s*|\s+0|\s+1)$/gu) {
			my $arg = $1;
			$arg = trim $1 if (defined $1);

			if (defined $arg && $arg !~ /^\s*$/) {
				if ($arg == 1) {
					$reply = ChanMsgToggle ($chatid, 1);
				} elsif ($arg == 0) {
					$reply = ChanMsgToggle ($chatid, 0);
				}
			} else {
				$reply = ChanMsgStatus ($chatid);
			}
		} elsif ($cmd =~ /^admin\s+(greet|приветствие)(\s*|\s+0|\s+1)$/gu) {
			my $arg = $2;
			$arg = trim $2 if (defined $2);

			if (defined $arg &&  $arg !~ /^\s*$/) {
				if ($arg == 1) {
					$reply = GreetMsgToggle ($chatid, 1);
				} elsif ($arg == 0) {
					$reply = GreetMsgToggle ($chatid, 0);
				}
			} else {
				$reply = GreetMsgStatus ($chatid);
			}
		} elsif ($cmd =~ /^admin\s+(goodbye|прощание)(\s*|\s+0|\s+1)$/gu) {
			my $arg = $2;
			$arg = trim $2 if (defined $2);

			if (defined $arg &&  $arg !~ /^\s*$/) {
				if ($arg == 1) {
					$reply = GoodbyeMsgToggle ($chatid, 1);
				} elsif ($arg == 0) {
					$reply = GoodbyeMsgToggle ($chatid, 0);
				}
			} else {
				$reply = GoodbyeMsgStatus ($chatid);
			}
		} elsif ($cmd =~ /^admin\s+oboobs(\s*|\s+0|\s+1)$/gu) {
			my $arg = $1;
			$arg = trim $1 if (defined $1);

			if (defined $arg) {
				if ($arg == 1) {
					$reply = PluginToggle ($chatid, 'oboobs', 1);
				} elsif ($arg == 0) {
					$reply = PluginToggle ($chatid, 'oboobs', 0);
				}
			} else {
				$reply = PluginStatus ($chatid, 'oboobs');
			}
		} elsif ($cmd =~ /^admin\s+obutts(\s*|\s+0|\s+1)$/gu) {
			my $arg = $1;
			$arg = trim $1 if (defined $1);

			if (defined $arg) {
				if ($arg == 1) {
					$reply = PluginToggle ($chatid, 'obutts', 1);
				} elsif ($arg == 0) {
					$reply = PluginToggle ($chatid, 'obutts', 0);
				}
			} else {
				$reply = PluginStatus ($chatid, 'obutts');
			}
		}
	}

	return $reply;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
