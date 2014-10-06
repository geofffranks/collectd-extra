package Collectd::Plugins::Load;
use strict;
use warnings;

use Collectd::Extra;
use Collectd qw/:all/;

sub read_load
{
	my $PROC = $ENV{TEST_COLLECTD_LOAD} || "/proc/loadavg";
	my @load = SLURP($PROC);
	unless (@load) {
		plugin_log LOG_ERR, "No output found from $PROC";
		return;
	}
	my ($short, $med, $long) = split /\s+/, $load[0];
	$PROC = $ENV{TEST_COLLECTD_CPUINFO} || "/proc/cpuinfo";
	my @cpuinfo = SLURP($PROC);
	my $cpus = 0;
	for (@cpuinfo) {
		$cpus++ if (/^processor\s*:\s*\d+/);
	}

	plugin_dispatch_values({ plugin => "nft_load", type => "load_1min",  values => [ $short ] });
	plugin_dispatch_values({ plugin => "nft_load", type => "load_5min",  values => [ $med ] });
	plugin_dispatch_values({ plugin => "nft_load", type => "load_15min", values => [ $long ] });
	plugin_dispatch_values({ plugin => "nft_load", type => "processor_count",  values => [ $cpus ] });
	1;
}

plugin_register(TYPE_READ, "nft_load", "read_load");

1;

=head1 NAME

Collectd::Plugins::Load - Collect system openfile usage metrics

=head1 SYNOPSIS

Retrieves data from /proc/loadavg for load data, and /proc/cpuinfo
for processor count, and submits to collectd.

=head1 FUNCTIONS

=head2 read_load

Callback handler for Collectd.pm to read data for system load.

Registers the 1min, 5min, 15min, and cpus datapoints under the 'nft_load' plugin.

=head1 AUTHOR

Geoff Franks, C<< <geoff.franks at gmail.com> >>

=cut
