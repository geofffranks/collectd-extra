package Collectd::Plugins::CPU;
use strict;
use warnings;

use Collectd::Extra;
use Collectd qw/:all/;

sub read_cpu
{
	my $PROC = $ENV{TEST_COLLECTD_CPU} || "/proc/stat";
	my @cpu = split /\s+/, (grep { /^cpu\b/ } (SLURP("$PROC")))[0];
	shift @cpu;
	unless (scalar(@cpu) == 10) {
		plugin_log LOG_ERR, "Unable to parse cpu line from $PROC, got ".scalar(@cpu)." items";
		return;
	}
	my $i = 0;

	for (qw/user nice system idle iowait irq softirq steal guest guest_nice/) {
		plugin_dispatch_values({ plugin => "cpu", type => "cpu_$_", values => [ $cpu[$i] ]});
		$i++;
	}
	1;
}

plugin_register(TYPE_READ, "cpu", "read_cpu");

1;

=head1 NAME

Collectd::Plugins::CPU - Collect system CPU statistics

=head1 SYNOPSIS

Retrieves data from /proc/stat and submits cpu performance metrics to collectd.

=head1 FUNCTIONS

=head2 read_cpu

Callback handler for Collectd.pm to read cpu data from /proc/stat.

Submits data for cpu_user, cpu_nice, cpu_system, cpu_idle, cpu_iowait, cpu_irq,
cpu_softirq, cpu_steal, cpu_guest, cpu_guest_nice datapoints on the 'cpu' plugin.

=head1 AUTHOR

Geoff Franks, C<< <geoff.franks at gmail.com> >>

=cut
