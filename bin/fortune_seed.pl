#!/usr/bin/perl

use 5.018;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use English qw( -no_match_vars );
use vars qw/$VERSION/;
$VERSION = '1.0';

my $workdir;

# before we run, change working dir
BEGIN {
	use Cwd qw(chdir abs_path);
	my @CWD = split /\//xms, abs_path ($PROGRAM_NAME);
	if ($#CWD > 1) { $#CWD = $#CWD - 2; }
	$workdir = join '/', @CWD;
	chdir $workdir;
}

use lib ("$workdir/lib", "$workdir/vendor_perl", "$workdir/vendor_perl/lib/perl5");
use fortune qw(seed fortune);
use Carp;
local $SIG{__DIE__} = sub { Carp::confess @_ };

seed ();
exit 0;
