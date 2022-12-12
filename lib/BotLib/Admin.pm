package BotLib::Admin;

use 5.018; ## no critic (ProhibitImplicitImport)
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use CHI ();
use CHI::Driver::BerkeleyDB ();
use BotLib::Conf qw (LoadConf);
use BotLib::Util qw (utf2sha1);

use version; our $VERSION = qw (1.1);
use Exporter qw (import);
# to export array we need @ISA here
our @ISA    = qw / Exporter /; ## no critic (ClassHierarchies::ProhibitExplicitISA)
our @EXPORT_OK = qw (@ForbiddenMessageTypes @PluginList GetForbiddenTypes AddForbiddenType DelForbiddenType
                     ListForbidden FortuneToggle FortuneToggleList FortuneStatus PluginToggle PluginStatus
                     PluginEnabled ChanMsgToggle ChanMsgStatus ChanMsgEnabled GreetMsgToggle GreetMsgStatus
                     GreetMsgEnabled GoodbyeMsgToggle GoodbyeMsgStatus GoodbyeMsgEnabled MigrateSettingsToNewChatID);

my $c = LoadConf ();
my $cachedir = $c->{cachedir};
# this list is not yet used
our @PluginList = qw (oboobs obutts); ## no critic (Variables::ProhibitPackageVars)
our @ForbiddenMessageTypes = qw (audio voice photo video video_note animation sticker dice game poll document); ## no critic (Variables::ProhibitPackageVars)

sub GetForbiddenTypes {
	my $chatid = shift;
	my $messageTypes;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid),
	);

	foreach (@ForbiddenMessageTypes) {
		my $type = $cache->get ($_);

		if ($type) {
			$messageTypes->{$_} = 1;
		} else {
			unless (defined $type) {
				$cache->set ($_, 0, 'never');
			}

			$messageTypes->{$_} = 0;
		}
	}

	return $messageTypes;
}

sub AddForbiddenType {
	my $chatid = shift;
	my $type = shift;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid),
	);

	$cache->set ($type, 1, 'never');
	return;
}

sub DelForbiddenType {
	my $chatid = shift;
	my $type = shift;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid),
	);

	$cache->remove ($type);
	return;
}

sub ListForbidden {
	my $chatid = shift;
	my @list;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid),
	);

	foreach (@ForbiddenMessageTypes) {
		my $type = $cache->get ($_);

		if ($type) {
			push @list, sprintf 'Тип сообщения %s удаляется', $_;
		} else {
			unless (defined $type) {
				$cache->set ($_, 0, 'never');
			}

			push @list, sprintf 'Тип сообщения %s не удаляется', $_;
		}
	}

	return join "\n", @list;
}

sub StatusForbidden {
	my $chatid = shift;
	my $ftype  = shift;

	my $cache = CHI->new (
		driver    => 'BerkeleyDB',
		root_dir  => $cachedir,
		namespace => __PACKAGE__ . '_' . 'censor' . '_' . utf2sha1 ($chatid),
	);

	my $type = $cache->get ($ftype);

	if ($type) {
		return 1;
	} else {
		unless (defined $type) {
			$cache->set ($ftype, 0, 'never');
		}

		return 0;
	}
}

sub FortuneToggle (@) {
	my $chatid = shift;
	my $action = shift // undef;
	my $phrase = 'Фортунка с утра ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'fortune',
	);

	my $state = $cache->get ($chatid);

	if (defined $action) {
		if ($action) {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'будет показываться.';
		} else {
			if (defined $state) {
				$cache->remove ($chatid);
			}

			$phrase .= 'не будет показываться.';
		}
	} else {
		if (defined $state && $state) {
			$cache->remove ($chatid);
			$phrase .= 'не будет показываться.';
		} else {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'будет показываться.';
		}
	}

	return $phrase;
}

sub FortuneStatus ($) {
	my $chatid = shift;
	my $phrase = 'Фортунка с утра ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'fortune',
	);

	my $state = $cache->get ($chatid);

	if (defined $state && $state) {
		$phrase .= 'показывается.';
	} else {
		$phrase .= 'не показывается.';
	}

	return $phrase;
}

sub FortuneToggleList () {
	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'fortune',
	);

	return $cache->get_keys ();
}

sub ChanMsgToggle (@) {
	my $chatid = shift;
	my $action = shift // undef;
	my $phrase = 'Сообщения, пришедшие от имени каналов ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'chan_msg',
	);

	my $state = $cache->get ($chatid);

	if (defined $action) {
		if ($action) {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'не будут удаляться.';
		} else {
			if (defined $state && $state) {
				$cache->set ($chatid, 0, 'never');
				$phrase .= 'будут удаляться.';
			} else {
				$cache->set ($chatid, 1, 'never');
				$phrase .= 'не будут удаляться.';
			}
		}
	} else {
		if (defined $state){
			if ($state) {
				$cache->set ($chatid, 0, 'never');
				$phrase .= 'будут удаляться.';
			} else {
				$cache->set ($chatid, 1, 'never');
				$phrase .= 'не будут удаляться.';
			}
		} else {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'не будут удаляться.';
		}
	}

	return $phrase;
}

sub ChanMsgStatus ($) {
	my $chatid = shift;
	my $phrase = 'Сообщения, пришедшие от имени каналов ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'chan_msg',
	);

	my $state = $cache->get ($chatid);

	if (defined $state) {
		if ($state) {
			$phrase .= 'не удаляются.';
		} else {
			$phrase .= 'удаляются.';
		}
	} else {
		$phrase .= 'не удаляются.';
	}

	return $phrase;
}

sub ChanMsgEnabled ($) {
	my $chatid = shift;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'chan_msg',
	);

	my $state = $cache->get ($chatid);

	if (defined $state) {
		if ($state) {
			return 1;
		} else {
			return 0;
		}
	} else {
		return 1;
	}
}

sub ChanMsgToggleList () {
	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'chan_msg',
	);

	return $cache->get_keys ();
}

sub GreetMsgToggle (@) {
	my $chatid = shift;
	my $action = shift // undef;
	my $phrase = 'Приветствия новых участников чата ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'greet_msg',
	);

	if (defined $action) {
		if ($action == 0) {
			$cache->set ($chatid, 0, 'never');
			$phrase .= 'выключены.';
		} else {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'включены.';
		}
	} else {
		my $state = $cache->get ($chatid);

		if (defined $state) {
			if ($state != 0) {
				$cache->set ($chatid, 0, 'never');
				$phrase .= 'выключены.';
			} else {
				$cache->set ($chatid, 1, 'never');
				$phrase .= 'включены.';
			}
		} else {
			$cache->set ($chatid, 0, 'never');
			$phrase .= 'выключены.';
		}
	}

	return $phrase;
}

sub GreetMsgStatus ($) {
	my $chatid = shift;
	my $phrase = 'Приветствия новых участников чата ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'greet_msg',
	);

	my $state = $cache->get ($chatid);

	if (defined $state) {
		if ($state) {
			$phrase .= 'включено.';
		} else {
			$phrase .= 'выключено.';
		}
	} else {
		$phrase .= 'включено.';
	}

	return $phrase;
}

sub GreetMsgEnabled ($) {
	my $chatid = shift;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'greet_msg',
	);

	my $state = $cache->get ($chatid);

	if (defined $state) {
		if ($state) {
			return 1;
		} else {
			return 0;
		}
	} else {
		return 1;
	}
}

sub GoodbyeMsgToggle (@) {
	my $chatid = shift;
	my $action = shift // undef;
	my $phrase = 'Прощание с ушедшими участниками чата ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'goodbye_msg',
	);

	my $state = $cache->get ($chatid);

	if (defined $action) {
		if ($action) {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'включено.';
		} else {
			$cache->set ($chatid, 0, 'never');
			$phrase .= 'выключено.';
		}
	} else {
		if (defined $state){
			if ($state) {
				$cache->set ($chatid, 0, 'never');
				$phrase .= 'выключено.';
			} else {
				$cache->set ($chatid, 1, 'never');
				$phrase .= 'включено.';
			}
		} else {
			$cache->set ($chatid, 1, 'never');
			$phrase .= 'включено.';
		}
	}

	return $phrase;
}

sub GoodbyeMsgStatus ($) {
	my $chatid = shift;
	my $phrase = 'Прощание с ушедшими участниками чата ';

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'goodbye_msg',
	);

	my $state = $cache->get ($chatid);

	if (defined $state) {
		if ($state) {
			$phrase .= 'включено.';
		} else {
			$phrase .= 'выключено.';
		}
	} else {
		$phrase .= 'выключено.';
	}

	return $phrase;
}

sub GoodbyeMsgEnabled ($) {
	my $chatid = shift;

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'goodbye_msg',
	);

	my $state = $cache->get ($chatid);

	if (defined $state) {
		if ($state) {
			return 1;
		} else {
			return 0;
		}
	} else {
		return 0;
	}
}

sub PluginStatus (@) {
	my $chatid = shift;
	my $plugin = shift;
	my $phrase = "Плагин $plugin ";

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'plugin' . '_' . utf2sha1 ($chatid),
	);

	my $state = $cache->get ($plugin);

	if ($state) {
		$phrase .= 'включён.';
	} else {
		unless (defined $state) {
			$cache->set ($plugin, 0, 'never');
		}

		$phrase .= 'выключен.';
	}

	return $phrase;
}

sub PluginEnabled (@) {
	my $chatid = shift;
	my $plugin = shift;

	# seems that we have point to return always true if chat is private
	if ($chatid > 0) {
		return 1;
	}

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'plugin' . '_' . utf2sha1 ($chatid),
	);

	my $state = $cache->get ($plugin);

	if (defined $state && $state) {
		return 1;
	} else {
		return 0;
	}
}

sub PluginToggle (@) {
	my $chatid = shift;
	my $plugin = shift;
	my $action = shift // undef;
	my $phrase = "Плагин $plugin ";

	my $cache = CHI->new (
		driver => 'BerkeleyDB',
		root_dir => $cachedir,
		namespace => __PACKAGE__ . '_' . 'plugin' . '_' . utf2sha1 ($chatid),
	);

	my $state = $cache->get ($plugin);

	if (defined $action) {
		if ($action) {
			$cache->set ($plugin, 1, 'never');
			$phrase .= 'включён';
		} else {
			$cache->set ($plugin, 0, 'never');
			$phrase .= 'выключен';
		}
	} else {
		if (defined ($state) && $state) {
			$cache->set ($plugin, 0, 'never');
			$phrase .= 'включён';
		} else {
			$cache->set ($plugin, 1, 'never');
			$phrase .= 'выключен';
		}
	}

	return $phrase;
}

sub MigrateSettingsToNewChatID {
	my $old_id = shift;
	my $new_id = shift;

	if (FortuneStatus ($old_id)) {
		FortuneToggle ($new_id, 1);
	} else {
		FortuneToggle ($new_id, 0);
	}

	if (ChanMsgStatus ($old_id)) {
		ChanMsgToggle ($new_id, 1);
	} else {
		ChanMsgToggle ($new_id, 0);
	}

	if (GreetMsgStatus ($old_id)) {
		GreetMsgToggle ($new_id, 1);
	} else {
		GreetMsgToggle ($new_id, 0);
	}

	if (GoodbyeMsgStatus ($old_id)) {
		GoodbyeMsgToggle ($new_id, 1);
	} else {
		GoodbyeMsgToggle ($new_id, 0);
	}

	# TODO: forbidden types

	foreach my $plugin (@PluginList) {
		if (PluginEnabled ($old_id, $plugin)) {
			PluginToggle ($new_id, $plugin, 1);
		} else {
			PluginToggle ($new_id, $plugin, 0);
		}
	}

	foreach my $ftype (@ForbiddenMessageTypes) {
		if (StatusForbidden($old_id, $ftype)) {
			AddForbiddenType($new_id, $ftype);
		}

		# Looks like we don't need to add forbiddent type for allowed types... right?
	}

	return;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
