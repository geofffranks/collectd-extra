#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::Collectd::Plugins typesdb => [ 'extra-types.db' ];

$ENV{TEST_COLLECTD_FILE_STATS} = "t/data/openfiles/good";
load_ok "Collectd::Plugins::OpenFiles";
read_ok "Collectd::Plugins::OpenFiles", "openfiles";

my @got = read_values "Collectd::Plugins::OpenFiles", "openfiles";
cmp_deeply \@got, [[{
		plugin => 'openfiles',
		type   => 'of_used',
		values => [ 184 ],
	}], [{
		plugin => 'openfiles',
		type   => 'of_max',
		values => [ 201494 ],
	}]], "Retrieved data out of OpenFiles, data was parsed properly"
	or diag explain \@got;

$ENV{TEST_COLLECTD_FILE_STATS} = "t/data/openfiles/bad";
@got = read_values "Collectd::Plugins::OpenFiles", "openfiles";
cmp_deeply \@got, [], "read_openfiles returns no values if it can't parse openfiles";

delete $ENV{TEST_COLLECTD_FILE_STATS};
@got = read_values "Collectd::Plugins::OpenFiles", "openfiles";
cmp_deeply \@got, [[{
		plugin => 'openfiles',
		type   => 'of_used',
		values => [ re('\d+') ],
	}], [{
		plugin => 'openfiles',
		type   => 'of_max',
		values => [ re('\d+') ],
	}]], "read_openfiles() appears to work on this system/kernel combo"
	or diag explain \@got;


done_testing;
