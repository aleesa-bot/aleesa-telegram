package RedisLib;

use 5.018; ## no critic (ProhibitImplicitImport)
use strict;
use warnings;
use utf8;
use English              qw ( -no_match_vars );
use open                 qw (:std :utf8);

use Data::Dumper         qw (Dumper);
use JSON::XS             qw (decode_json);
use Log::Any             qw ($log);
use Mojo::Redis             ();
use Mojo::Redis::Connection ();

use BotLib::Admin        qw (MigrateSettingsToNewChatID FortuneToggle);
use BotLib::Conf         qw (LoadConf);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (redis_parse_message redis_events_listener);

my $c = LoadConf ();

sub redis_parse_message {
	my $self = shift;
	my $m = shift;
	my $message;

	$log->debug ('Incoming redis message: ' . Dumper $m);

	# Мы "не можем" отправлять сообщения в телеграм, если мы к нему не подключены
	# (конечно, можем, но Teapot-lib предполагает, что объектик с чатом - это его собственность, а городить свой что-то
	# не очень хочется)
	until (defined $main::TGM) {
		sleep 1;
	}

	if ($m->{misc}->{msg_format}) {
		$message->{parse_mode} = 'Markdown';
	}

	$message->{chat_id} = eval { 0 + $m->{chatid}; };

	unless (defined $message->{chat_id}) {
		$log->error ('[ERROR] Incoming redis message is incorrect: chat id must be numeric value!');
		return;
	}

	if ($message->{chat_id} == 0) {
		$log->error ('[ERROR] Incoming redis message is incorrect: chat id must not be equal 0!');
		return;
	}

	$message->{text} = "$m->{message}";

	if (defined ($m->{threadid}) && $m->{threadid} ne '') {
		$message->{message_thread_id} = 0 + $m->{threadid};
	}

	# we cannot use $self->_brain->can_talk here because of $self pointing to redis object, not telegram
	my $can_talk = $main::TGM->can_talk ({ chat_id => 0 + $m->{chatid}});

	if ($can_talk->{error}) {
		$log->error ('[ERROR] Unable to guess if i can talk in this chat: ' . Dumper ($can_talk));
		return;
	}

	if ($can_talk->{can_talk}) {
		my $r = $main::TGM->sendMessage ($message);

		if ($r->{error}) {
			# TODO: handle 50x errors? They occur when api servers being updated.
			my $resp = eval { $r->{debug}->json };

			if (defined $resp) {
				if (defined ($resp->{error_code}) && $resp->{error_code} == 400) {
					if (defined $resp->{description}) {
						if ($resp->{description} eq 'Bad Request: not enough rights to send text messages to the chat') {
							$log->notice ("[NOTICE] Have no rights to send message to $m->{chatid}");
							# TODO: disable fortune if message is good morning fortune
						} elsif ($resp->{description} eq 'Bad Request: chat not found') {
							$log->notice (
								"[NOTICE] Chat not found toggling good morning fortune off for $m->{chatid}"
							);

							FortuneToggle($m->{chatid}, 0);
							return;
						} elsif ($resp->description eq 'Bad Request: group chat was upgraded to a supergroup chat') {
							if (defined ($resp->{parameters}) &&
								defined ($resp->{parameters}->{migrate_to_chat_id})) {
								my $tpl = '[NOTICE] group upgraded to supergroup, chat_id changed, ';
								$tpl   .= 'migrating settings from %s to %s';

								$log->notice (
									sprintf($tpl, $m->{chatid}, $resp->{parameters}->{migrate_to_chat_id})
								);

								MigrateSettingsToNewChatID (
									$m->{chatid},
									$resp->{parameters}->{migrate_to_chat_id}
								);
							}
						} else {
							$log->error ('[ERROR] Unable to call sendMessage() BotAPI method: ' . Dumper ($r));
						}
					} else {
						$log->error ('[ERROR] BotAPI returns parsable error: ' . Dumper ($resp));
					}
				} else {
					$log->error ('[ERROR] Unable to handle BotAPI error: ' . Dumper ($resp));
				}
			} else {
				$log->error ('[ERROR] Unable to call sendMessage() BotAPI method: ' . Dumper ($r));
			}
		}
	}

	return;
}

sub redis_events_listener {
	$log->notice ('[NOTICE] Run redis events listener');
	# If we already connected there is no point to disconnect
	if (defined $main::REDIS) {
		my $connected = eval { Mojo::Redis::Connection->is_connected ($main::REDIS); };

		if ($connected) {
			$log->notice ('[NOTICE] Redis client already running and connected');
			return;
		} else {
			$log->notice ('[NOTICE] Redis client registered, but looks like it is not connected, try to re-connect');
			$main::REDIS = undef;
		}
	}

	my $r = Mojo::Redis->new (
		sprintf 'redis://%s:%s/1', $c->{redis_server}, $c->{redis_port},
	);

	$log->notice ('[NOTICE] New redis client registered, registering callbacks');
	# Don't forget to update global ref to our redis context
	$main::REDIS = $r;

	$r->on (
		connection => sub {
			my ($redis, $connection) = @_;
			$main::RCONN = $connection;

			# Log error
			$connection->on (
				error => sub {
					my ($conn, $error) = @_;
					$log->error ("[ERROR] Redis connection error: $error");
					$main::RCONN = undef;
					return;
				},
			);

			return;
		},
	);

	# Subscribe to channels
	my $pubsub = $r->pubsub;
	my $sub;
	my $rpm = \&redis_parse_message;
	$log->notice ('[NOTICE] Subscribing to redis channels');

	foreach my $channel (@{$c->{redis_channels}}) {
		$log->info ("[INFO] Subscribing to $channel");

		$sub->{$channel} = $pubsub->json ($channel)->listen (
			$channel => sub { $rpm->(@_); },
		);
	}

	return;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
