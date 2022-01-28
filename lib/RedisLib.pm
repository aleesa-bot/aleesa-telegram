package RedisLib;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);

use Log::Any qw ($log);
# Чтобы "уж точно" использовать hiredis-биндинги, загрузим этот модуль перед Mojo::Redis
use Protocol::Redis::XS;
use Mojo::Redis;
use Mojo::Redis::Connection;

use BotLib::Conf qw (LoadConf);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (redis_parse_message redis_events_listener);

my $c = LoadConf ();

sub redis_parse_message {
	my $self = shift;
	my $m = shift;
	my $message;

	# Мы "не можем" отправлять сообщения в телеграм, если мы к нему не подключены
	# (конечно, можем, но Teapot-lib предполагает, что объектик с чатом - это его собственность, а городить свой что-то
	# не очень хочется)
	until (defined $main::TGM) {
		sleep 1;
	}

	if ($m->{misc}->{msg_format}) {
		$message->{parse_mode} = 'Markdown';
	}

	$message->{chat_id} = $m->{chatid};
	$message->{text} = $m->{message};

	if (Teapot::Bot::Object::ChatPermissions::canTalk ($main::TGM, $m->{chatid})) {
		# Результат этого действия нас не сильно волнует, т.к. если будет ошибка, то в лог попадёт трейс
		$main::TGM->sendMessage ($message);
	}

	return;
};

sub redis_events_listener {
	$log->notice ('[NOTICE]Run redis events listener');
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
		sprintf 'redis://%s:%s/1', $c->{redis_server}, $c->{redis_port}
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
				}
			);

			return;
		}
	);

	# Subscribe to channels
	my $pubsub = $r->pubsub;
	my $sub;
	my $rpm = \&redis_parse_message;
	$log->notice ('[NOTICE] Subscribing to redis channels');

	foreach my $channel (@{$c->{redis_channels}}) {
		$log->info ("[INFO] Subscribing to $channel");

		$sub->{$channel} = $pubsub->json ($channel)->listen (
			$channel => sub { $rpm->(@_); }
		);
	}

	return;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
