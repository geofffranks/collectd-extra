package Collectd::Extra;

use strict;
use Exporter;

our @ISA = "Exporter";
our @EXPORT = qw/SLURP/;
our $VERSION = '1.0.0';

sub SLURP
{
	my ($file) = @_;
	open my $fd, $file;
	my @lines = <$fd>;
	close $fd;
	return wantarray ? @lines : join("\n", @lines);
}

=head1 NAME

Collectd::Extra - A collection of collectd plugins targeted towards
monitoring Linux machines

=head1 SYNOPSIS

This is a collection of collectd plugins that collect system data on
behalf of collectd.

=head1 PLUGINS

=over

=item OpenFiles

Collects system-level open file metrics by examping /proc/sys/fs/file-nr

=item CPU

Collects aggregate CPU usage data recorded via sysstat. Differs from the
built-in CPU plugin collectd provides, in that it reports one dataset, regardless
of how many processors are present.

=item Load

Collects system load information. Differs from the built-in load plugin collectd
provies, in that it also reports the processor count of the host, to make for
better saled graphs.

=item OpenFiles

Collects system-level statistics on open file handles.

=item PageFaults

Collects system page-fault statistics as recorded by sysstat.

=item Process

Collects process-specific performance data, for processes matching a regex.
Gathers things like %cpu, memory usage, openfiles, io, thread count, and process
count for the process (via regexes).

=back

=head1 FUNCTIONS

=head2 SLURP($filename)

Reads in data from a given file, and returns either as an array of lines,
or a scalar of all text, with newline separation.

=head1 AUTHOR

Geoff Franks, C<< <geoff.franks at gmail.com> >>

=head1 BUGS

This software is bug free. And if you think you find one, (which you didn't, because 'bug-free'),
you'll just have to live with it, because we can't fix bugs that don't actually exist.

=head1 ACKNOWLEDGEMENTS

I'd like to thank the Academy of CPAN, and Collectd for making this possible;
my mother and father for creating me; and my wife for not divorcing me yet.

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Geoff Franks.

This program is distributed under the Gnu General Public License 3.0

=cut

1;
