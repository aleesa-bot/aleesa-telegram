package Cli;

# общие модули - синтаксис, кодировки итд
use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);

# модули для работы приложения
use Mojo::Redis;

use BolLib::Conf qw (LoadConf);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (RunCli);

my $c = LoadConf ();

sub RunCli {
	my $redis = Mojo::Redis->new (
		sprintf 'redis://%s:%s/1', $c->{redis_server}, $c->{redis_port}
	);

	my $pubsub = $redis->pubsub;
	my $send_to = 'telegram';

	$pubsub->json ($send_to)->notify (
		$send_to => {
			from    => 'redis_msg_gen.pl',
			userid  => '0',
			chatid  => 'some_chat_id',
			plugin  => 'redis_msg_gen.pl_plugin',
			message => 'ping?',
			mode    => 'mode',
		}
	);

	return;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
