#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::Collectd::Plugins typesdb => [ 'extra-types.db' ];

$ENV{TEST_COLLECTD_LOAD} = "t/data/load/loadavg";
$ENV{TEST_COLLECTD_CPUINFO} = "t/data/load/cpuinfo";
load_ok "Collectd::Plugins::Load";
read_ok "Collectd::Plugins::Load", "nft_load";

my @got = read_values "Collectd::Plugins::Load", "nft_load";
cmp_deeply \@got, [[{
		plugin => 'nft_load',
		type   => 'load_1min',
		values => [ 0.13 ],
	}], [{
		plugin => 'nft_load',
		type   => 'load_5min',
		values => [ 0.04 ],
	}], [{
		plugin => 'nft_load',
		type   => 'load_15min',
		values => [ 0.05 ],
	}], [{
		plugin => 'nft_load',
		type   => 'processor_count',
		values => [ 2 ],
	}]], "Retrieved data out of Load, data was parsed properly"
	or diag explain \@got;

done_testing;
