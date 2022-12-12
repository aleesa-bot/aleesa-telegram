package TelegramBot;
# main bot gears are here

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
use Mojo::Base 'Teapot::Bot::Brain';

use BotLib::Admin qw (FortuneToggleList ChanMsgEnabled GreetMsgEnabled GoodbyeMsgEnabled MigrateSettingsToNewChatID);
use BotLib qw (Command);
use BotLib::Conf qw (LoadConf);
use BotLib::Util qw (trim fmatch BotSleep Highlight IsCensored RandomCommonPhrase);
use RedisLib qw (redis_events_listener);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (RunTelegramBot);

my $c = LoadConf ();
my $myid;
my $myusername;
my $myfirst_name;
my $mylast_name;
my $myfullname;

has token => $c->{telegrambot}->{token};

my @introduce_greet = (
	'Дратути',
	'Дарована',
	'Доброе утро, день или вечер',
	'Добро пожаловать в наше скромное коммунити',
	'Наше вам с кисточкой тут, на канальчике',
);

my $redismsg->{from}              = 'telegram';
$redismsg->{threadid}             = '';
$redismsg->{plugin}               = 'telegram';
$redismsg->{misc}->{answer}       = 1;
$redismsg->{misc}->{csign}        = "$c->{telegrambot}->{csign}";
$redismsg->{misc}->{msg_format}   = 0;
$redismsg->{misc}->{fwd_cnt}      = 1;
$redismsg->{misc}->{good_morning} = 0;

sub __cron {
	my $self = shift;

	my $rmsg                      = clone ($redismsg);
	$rmsg->{mode}                 = 'public';
	# Press 'F' to pay respect
	$rmsg->{message}              = sprintf '%sf', $c->{telegrambot}->{csign};
	$rmsg->{misc}->{msg_format}   = 1;
	$rmsg->{misc}->{good_morning} = 1;

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime (time);

	{
		do {
			my $ready = eval { $main::RCONN->is_connected; };
			last if ($ready);
		} while (sleep 1);
	}

	my $pubsub = $main::REDIS->pubsub;

	if ($hour == 8 && ($min >= 0 && $min <= 14)) {
		foreach my $enabledfortunechat (FortuneToggleList ()) {
			# Set it to strings, explicitly
			next unless (defined $enabledfortunechat);
			next if ("$enabledfortunechat" eq '');
			next if ("$enabledfortunechat" eq '0');

			$rmsg->{userid}  = "$enabledfortunechat";
			$rmsg->{chatid}  = "$enabledfortunechat";

			$log->debug ('[DEBUG] Outgoing redis message: ' . Dumper ($rmsg));

			$pubsub->json ($c->{'redis_router_channel'})->notify (
				$c->{'redis_router_channel'} => $rmsg,
			);

			# Ratelimit this, just in case
			sleep (1);
		}
	}

	return;
}

sub __on_msg {
	my ($self, $msg) = @_;
	# chat info
	my $chatid;

	# Ловим сообщения о миграции.
	if ($msg->can ('migrate_to_chat_id') && $msg->can ('migrate_from_chat_id')) {
		if (defined ($msg->migrate_from_chat_id) && defined ($msg->migrate_from_chat_id)) {
			MigrateSettingsToNewChatID ($msg->migrate_from_chat_id, $msg->migrate_to_chat_id);
		}

		return;
	}

	my $chatname = 'Noname chat';
	# user sending message info
	my ($userid, $username, $fullname, $highlight, $vis_a_vi) = Highlight ($msg);
	my $csign = $c->{telegrambot}->{csign};

	unless ($myid) {
		my $myObj = $self->getMe ();

		if ($myObj->{error}) {
			return;
		}

		$myid = $myObj->id;
		$myusername = $myObj->username;
		$myfirst_name = $myObj->first_name;
		$mylast_name = $myObj->last_name;

		if (defined ($myfirst_name) && ($myfirst_name ne '') && defined ($mylast_name) && ($mylast_name ne '')) {
			$myfullname = $myfirst_name . ' ' . $mylast_name;
		} elsif (defined ($myfirst_name) && ($myfirst_name ne '')) {
			$myfullname = $myfirst_name;
		} elsif (defined ($mylast_name) && ($mylast_name ne '')) {
			$myfullname = $mylast_name;
		} else {
			$myfullname = $myusername;
		}
	}

	if ($msg->chat->can ('id') && defined ($msg->chat->id)) {
		$chatid = $msg->chat->id;

		if ($msg->chat->can ('username') && defined ($msg->chat->username)) {
			$chatname = $msg->chat->username ;
		} else {
			if ($msg->chat->can ('title') && defined ($msg->chat->title)) {
				$chatname = $msg->chat->title;
			} else {
				$chatname = 'Noname chat';
			}
		}
	} else {
		$log->warn ('[INFO] Unable to get chatid');
		return;
	}

	my $phrase = '';

	# Newcommer event, greet our new member and suggest to introduce themself.
	if ($msg->can ('new_chat_members') && defined ($msg->new_chat_members)) {
		unless (GreetMsgEnabled ($chatid)) {
			return;
		}

		# Новые юзеры пачками появляются, только если их кто-то добавил через клиента
		my @members;

		foreach my $member (@{$msg->new_chat_members}) {
			my $member_str = '';

			# Избегаем именования по пробельному символу
			if ($member->can ('first_name') && defined ($member->first_name) && $member->first_name !~ /^\s+$/ui) {
				$member_str .= $member->first_name;

				if ($member->can ('last_name') && defined ($member->last_name) && $member->last_name !~ /^\s+$/ui) {
					$member_str .= ' ' . $member->last_name;
				}
			} else {
				if ($member->can ('last_name') && defined ($member->last_name) && $member->last_name !~ /^\s+$/ui) {
					$member_str .= ' ' . $member->last_name;
				# Username - это у нас валидная строка из только английских символов
				} elsif ($member->can ('username') && defined ($member->username)) {
					$member_str .= '@' . $member->username;
				# Если у юзера нету подходящих имени, фамилии или username, будем пользовать его id
				} else {
					$member_str .= $member->id;
				}
			}

			push @members, sprintf '[%s](tg://user?id=%s)', $member_str, $member->id;
		}

		if ($#members > 1) {
			my $lastone = pop @members;
			$phrase = sprintf (
				'%s, %s и %s. Представьтес, пожалуйста, и расскажите, что вас сюда привело.',
				$introduce_greet[irand ($#introduce_greet + 1)],
				join (', ', @members),
				$lastone,
			);
		} else {
			$phrase = sprintf (
				'%s, %s. Представьтес, пожалуйста, и расскажите, что вас сюда привело.',
				$introduce_greet[irand ($#introduce_greet + 1)],
				$members[0],
			);
		}

		BotSleep $msg;
		$msg->replyMd ($phrase);
		return;
	}

	# Leaving event, say goodbye to member just left chat
	if ($msg->can ('left_chat_member') && defined ($msg->left_chat_member)) {
		unless (GoodbyeMsgEnabled ($chatid)) {
			return;
		}

		my @goodbye = (
			'Чат покинул(а) %s',
			'Из чата вышел(ла) %s',
			'До свидания, %s, приходите ещё',
			'Покеда, %s',
			'Удачи тебе, %s',
			'Бывай, %s',
		);

		my $member = $msg->left_chat_member;
		my $member_str = '';

		# avoid naming people by spacing symbols, or empty names
		if ($member->can ('first_name') && defined ($member->first_name) && $member->first_name !~ /^\s+$/ui) {
			$member_str .= $member->first_name;

			if ($member->can ('last_name') && defined ($member->last_name) && $member->last_name !~ /^\s+$/ui) {
				$member_str .= ' ' . $member->last_name;
			}
		} else {
			if ($member->can ('last_name') && defined ($member->last_name) && $member->last_name !~ /^\s+$/ui) {
				$member_str .= ' ' . $member->last_name;
			# username must be uniq and should contain only english letters and numbers, so...
			} elsif ($member->can ('username') && defined ($member->username)) {
				$member_str .= '@' . $member->username;
			# fallback to id if uose trying to be smartass and use only spacing chars in it's firstname and/or lastname
			} else {
				$member_str .= $member->id;
			}
		}

		my $leftuser = sprintf '[%s](tg://user?id=%s)', $member_str, $member->id;
		$phrase = sprintf $goodbye[irand ($#goodbye + 1)], $leftuser;
		$msg->replyMd ($phrase);
		return;
	}

	# is this a 1-on-1 ?
	if ($msg->chat->type eq 'private') {
		unless (defined $msg->text) {
			return;
		}

		my $text = $msg->text;
		$log->debug (sprintf ('[DEBUG] Private chat %s say to bot: %s', $vis_a_vi, $text));
		# Ответ по-умолчанию
		my $reply = 'Давайте ещё пообщаемся, а то я ещё не научилась от вас плохому.';

		if ((length $text > length $csign)  &&  substr ($text, 0, length ($csign)) eq $csign) {
			# Если текст похож на команду, усылаем его в BotLib.pm
			$reply = Command ($self, $msg, $text, $userid);
		} else {
			my $rmsg                = clone ($redismsg);
			$rmsg->{mode}           = 'private';
			$rmsg->{message}        = "$text";
			# Set it to strings, explicitly
			$rmsg->{userid}         = "$userid";
			$rmsg->{chatid}         = "$userid";
			$rmsg->{misc}->{answer} = 1;

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

			return;
		}

		# Команды раздела Admin ответ таки возвращают
		if (defined $reply) {
			$msg->typing ();
			sleep 1;
			$log->debug (sprintf ('[DEBUG] Private chat bot reply to %s: %s', $vis_a_vi, $reply));
			$msg->reply ($reply);
		}
	# group chat
	} elsif (($msg->chat->type eq 'supergroup') or ($msg->chat->type eq 'group')) {
		my $reply;

		# Некоторые виды сообщений можно "зацензурить" ботом, например, голосовые сообщения, картинки итд.
		# И вот тут как раз такая проверка и происходит
		if (IsCensored $msg) {
			$log->info (sprintf '[INFO] In public chat %s (%s) message from %s was censored', $chatname, $chatid, $vis_a_vi);
			$self->deleteMessage ({chat_id => $chatid, message_id => $msg->{message_id}});
		}

		# Некоторые рекламные товарищи пытаются срать своими каналами в чятик это тоже можно зацензурить ботом и это
		# пидорство он будет удалять asap
		# 136817688 - это специальный id пользователя, который принимает облик канала, на него можно нажать и попасть
		#              на рекламируемый канал
		if ($msg->from->id == 136817688) {
			my $sender_chat = eval { $msg->sender_chat->id };

			if (defined $sender_chat) {
				unless (ChanMsgEnabled ($chatid)) {
					$self->deleteMessage ({chat_id => $chatid, message_id => $msg->{message_id}});
				}
			}
		}

		# Если обнаруживаем здесь сообщение без текста, просто ничего не делаем и выходим из процедуры обработки
		# сообщения
		unless (defined $msg->text) {
			$log->debug (sprintf ('[DEBUG] No text in message from %s', $vis_a_vi));
			return;
		}

		# Текст есть, потенциально можно будет поболтать!
		my $text = $msg->text;
		$log->debug (sprintf ('[DEBUG] In public chat %s (%s) %s say: %s', $chatname, $chatid, $vis_a_vi, $text));

		# Если это ответ на сообщение, то вдруг, на наше?
		if (defined ($msg->reply_to_message) &&
		            defined ($msg->reply_to_message->from) &&
		                    defined ($msg->reply_to_message->from->username) &&
		                            ($msg->reply_to_message->from->username eq $myusername)) {
			$log->debug (sprintf ('[DEBUG] In public chat %s (%s) %s quote us!', $chatname, $chatid, $vis_a_vi));

			# Если новый участник чата ответил на наше приветствие, проигнорируем его ответ (и попробуем сойти за
			# человека :)
			my $greetphrase = 'Представьтес, пожалуйста, и расскажите, что вас сюда привело.';

			if ($msg->reply_to_message->text =~ /\Q$greetphrase\E$/u) {
				foreach my $hi (@introduce_greet) {
					if ($msg->reply_to_message->text =~ /^\Q$hi\E\, /u) {
						return;
					}
				}
			}

			# На всякий случай, попробуем убрать наше имя из фразы.
			my $pat1 = quotemeta ('@' . $myusername);
			my $pat2 = quotemeta $myfullname;
			$phrase = $text;
			$phrase =~ s/$pat1//g;
			$phrase =~ s/$pat2//g;

			# Попробуем сгенерить ответ
			my $rmsg                = clone ($redismsg);
			$rmsg->{mode}           = 'public';
			$rmsg->{message}        = "$phrase";
			# Set it to strings, explicitly
			$rmsg->{userid}         = "$userid";
			$rmsg->{chatid}         = "$chatid";
			$rmsg->{misc}->{answer} = 1;

			# Если тип группы supergroup, в ней могут быть треды, попробуем найти message_thread_id, если таковой есть
			if ($msg->chat->type eq 'supergroup') {
				if ($msg->can ('is_topic_message') && $msg->is_topic_message) {
					if ($msg->can ('message_thread_id') && $msg->message_thread_id ne '') {
						$rmsg->{threadid} = "$msg->message_thread_id";
					}
				}
			}

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

			return;
		# Если текст похож на команду, усылаем его в BotLib.pm
		} elsif ((length $text > length $csign)  &&  substr ($text, 0, length ($csign)) eq $csign) {
			$reply = Command ($self, $msg, $text, $chatid);
		# Похоже кто-то написал наше имя в чятике, но ничего не захотел дописывать к нему
		} elsif (
				($text eq $myusername) or
				($text eq '@' . $myusername) or
				($text eq '@' . $myusername . ' ') or
				($text eq $myfullname) or
				($text eq $myfullname . ' ')
			) {
				$reply = 'Чего?';
		# А тут кто-то к нам обратился с чем-то по имени
		} else {
			my $qname = quotemeta ('@' . $myusername);
			my $qtname = quotemeta $myfullname;

			my $rmsg                = clone ($redismsg);
			$rmsg->{mode}           = 'public';
			# Set it to strings, explicitly
			$rmsg->{userid}         = "$userid";
			$rmsg->{chatid}         = "$chatid";
			$rmsg->{misc}->{answer} = 1;

			# Если тип группы supergroup, в ней могут быть треды, попробуем найти message_thread_id, если таковой есть
			if ($msg->chat->type eq 'supergroup') {
				if ($msg->can ('is_topic_message') && $msg->is_topic_message) {
					if ($msg->can ('message_thread_id') && $msg->message_thread_id ne '') {
						$rmsg->{threadid} = "$msg->message_thread_id";
					}
				}
			}

			# Сообщение обращено к боту
			if ((lc ($text) =~ /^${qname}[\,|\:]? (.+)/) or (lc ($text) =~ /^${qtname}[\,|\:]? (.+)/)){
				$phrase = $1;
				$rmsg->{message} = "$phrase";
			# Бота упомянули по имени
			} elsif ((lc ($text) =~ /.+ ${qname}[\,|\!|\?|\.| ]/) or (lc ($text) =~ / $qname$/)) {
				$phrase = $text;
				$rmsg->{message} = "$phrase";
			# Бота упомянули по телеграммному имени
			} elsif ((lc ($text) =~ /.+ ${qtname}[\,|\!|\?|\.| ]/) or (lc ($text) =~ / $qtname$/)) {
				$phrase = $text;

				$rmsg->{message} = "$phrase";
			} else {
				$rmsg->{message} = "$text";
				$rmsg->{misc}->{answer} = 0;
			}

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

			return;
		}

		if (defined ($reply) && $reply ne '') {
			# work a bit more on input phrase
			$phrase = trim $phrase;

			while ($phrase =~ /[\.|\,|\?|\!]$/) {
				chop $phrase;
			}

			$phrase = lc $phrase;

			if (fmatch (lc ($reply), $phrase)) {
				$reply = RandomCommonPhrase ();
			}

			$msg->typing ();
			sleep (irand 2);
			$log->debug (
				sprintf (
					'[DEBUG] In public chat %s (%s) bot reply to %s: %s',
					$chatname, $chatid, $vis_a_vi, $reply,
				)
			);
			$msg->reply ($reply);
		} else {
			$log->debug (
				sprintf (
					'[DEBUG] In public chat %s (%s) bot is not required to reply to %s',
					$chatname, $chatid, $vis_a_vi,
				)
			);
		}

	# should be channel, so we can't talk
	} else {
		return;
	}

	return;
}


# setup our bot
sub init {
	my $self = shift;

	# Don't forget to update global ref to our telegram context
	$main::TGM = $self;

	$self->add_listener (\&__on_msg);
	$self->add_repeating_task (900, \&__cron);
	redis_events_listener ();
	return;
}

sub RunTelegramBot {
	while (sleep 3) {
		eval {                                       ## no critic (ErrorHandling::RequireCheckingReturnValueOfEval)
			TelegramBot->new->think;
		};
	}

	return;
}

1;

# vim: ft=perl noet ai ts=4 sw=4 sts=4:
