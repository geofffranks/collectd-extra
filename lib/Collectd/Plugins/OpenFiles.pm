package Collectd::Plugins::OpenFiles;
use strict;
use warnings;

use Collectd::Extra;
use Collectd qw/:all/;

sub read_openfiles
{
	my $PROC = $ENV{TEST_COLLECTD_FILE_STATS} || "/proc/sys/fs/file-nr";
	my @of = SLURP($PROC);
	unless (@of) {
		plugin_log LOG_ERR, "No output found from $PROC";
		return;
	}
	my ($used, $free, $max) = split /\s+/, $of[0];
	plugin_dispatch_values({ plugin => "openfiles", type => "of_used", values => [ $used ] });
	plugin_dispatch_values({ plugin => "openfiles", type => "of_max",  values => [ $max ] });
}

plugin_register(TYPE_READ, "openfiles", "read_openfiles");

1;

=head1 NAME

Collectd::Plugins::OpenFiles - Collect system openfile usage metrics

=head1 SYNOPSIS

Retrieves data from /proc/sys/fs/file-nr and submits openfile utilization
metrics to collectd.

=head1 FUNCTIONS

=head2 read_openfiles

Callback handler for Collectd.pm to read data for openfiles.

Registers the of_used, and of_max datapoints on the openfiles plugin.

=head1 AUTHOR

Geoff Franks, C<< <geoff.franks at gmail.com> >>

=cut
