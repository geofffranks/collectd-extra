package Collectd::Plugins::PageFault;
use strict;
use warnings;

use Collectd::Extra;
use Collectd qw/:all/;

sub read_vmstat
{
	my $PROC = $ENV{TEST_COLLECTD_PAGEFAULT} || "/proc/vmstat";
	my @stats = SLURP("$PROC");
	unless (@stats) {
		plugin_log LOG_ERR, "Unable to parse data from $PROC";
		return;
	}

	for (@stats) {
		if (/^(pgpgin|pgpgout|pgfault|pgmajfault)\s+(\d+)/) {
			plugin_dispatch_values({ plugin => "pagefaults", type => "pf_$1", values => [ $2 ]});
		}
	}
	1;
}

plugin_register(TYPE_READ, "pagefaults", "read_vmstat");

1;

=head1 NAME

Collectd::Plugins::PageFault - Collect system page fault statistics

=head1 SYNOPSIS

Collects page fault statistics from /proc/vmstat

=head1 FUNCTIONS

=head2 read_vmstat

Callback handler for Collectd.pm to read memory data from /proc/vmstat.

Submits data for pf_pgpgin, pf_pgpout, pf_pgfault, pf_pgmajfault datapoints on the 'pagefaults'
plugin.

=head1 AUTHOR

Geoff Franks, C<< <geoff.franks at gmail.com> >>

=cut
