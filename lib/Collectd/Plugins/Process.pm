package Collectd::Plugins::Process;
use strict;
use warnings;

use Collectd::Extra;
use POSIX;
use threads;
use threads::shared;
use Collectd qw/:all/;

my @PROCS : shared = ();

sub proc_cfg
{
	my ($cfg) = @_;
	if ($cfg->{values}[0] eq "proc") {
		lock @PROCS;
		for my $obj (@{$cfg->{children}}) {
			if ($obj->{key} eq "Process") {
				my %process : shared = ();
				lock %process;
				for my $key (@{$obj->{children}}) {
					if ($key->{key} eq 'Name') {
						$process{name}  = $key->{values}[0];
						$process{regex} = $key->{values}[0]
							unless $process{regex};
					}
					if ($key->{key} eq 'Regex') {
						$process{regex} = $key->{values}[0];
					}
					if ($key->{key} eq 'ChildStats') {
						$process{children} = $key->{values}[0];
					}
				}
				if ($process{name} && $process{regex}) {
					push @PROCS, \%process;
				} else {
					plugin_log LOG_ERR, "No Name/Regex specified for one of the"
						. "configured processes. Skipping";
				}
			}
		}
	}
	1;
}

sub get_pid
{
	my ($regex) = @_;
	my @pids = split /\n/s, qx|pgrep -f -P 1 $regex|;
	plugin_log LOG_WARNING, "Multiple parent processes found, try adjusting the regex";
	return $pids[0]; # just match the first one
}

sub get_children
{
	my ($parent) = @_;
	my @pids = split /\n/s, qx|pgrep -P $parent|;
	push @pids, get_children($_) for (@pids);
	return @pids;
}

sub pidstats
{
	my ($pid) = @_;
	my $data = {};
	$data->{processes} = 1;

	opendir my $of, $ENV{TEST_PROC_FD} || "/proc/$pid/fd";
	$data->{openfiles} = scalar(grep { ! /^\./ } readdir $of);
	close $of;

	for (SLURP $ENV{TEST_PROC_STATUS} || "/proc/$pid/status") {
		if ($_ =~ /^(VmPeak|VmSize|VmRSS|VmHWM):\s+(\d+)/) {
			$data->{lc($1)} = $2 * 1024;
		}
		if ($_ =~ /^Threads:\s+(\d+)/) {
			$data->{threads} = $1;
		}
	}

	my @pidstat = split / /, SLURP $ENV{TEST_PROC_STAT} || "/proc/$pid/stat";
	$data->{utime}      = $pidstat[13] / CLOCKS_PER_SEC;
	$data->{stime}      = $pidstat[14] / CLOCKS_PER_SEC;
	$data->{guest_time} = $pidstat[42] / CLOCKS_PER_SEC;
	$data->{iowait}     = $pidstat[41] / CLOCKS_PER_SEC;

	return $data;
}

sub read_processes
{
	lock @PROCS;
	for my $proc (@PROCS) {
		my $ppid = get_pid($proc->{regex});
		next unless $ppid; # this should really log, but logging is useless in read handlers?

		my $stats = pidstats($ppid);

		if ($proc->{children}) {
			my @pids = get_children($ppid);
			for my $kid (@pids) {
				my $data = pidstats($kid);
				$stats->{$_} += $data->{$_} for (keys %$data);
			}
		}

		for (keys %$stats) {
			my $name = $proc->{name};
			my $stat = $_;
			$name =~ s|/|_|g;
			$stat =~ s|/|_|g;
			plugin_dispatch_values({
				plugin => "proc",
				type   => "ps_$stat",
				values => [ $stats->{$_} ],
				plugin_instance => $name,
			});
		}
	}
	1;
}

plugin_register(TYPE_CONFIG, "proc", "proc_cfg");
plugin_register(TYPE_READ,   "proc", "read_processes");

1;

=head1 NAME

Collectd::Plugins::Process - Collect process-level stastics for specific processes.

=head1 SYNOPSIS

Retrieves performance data for specifically defined processes, and reports them
to collectd.

=head1 CONFIGURATION

Multiple plugin declarations are allowed for processes, each of which should
be used for a single set of processes. Matches only the processes whose parent
PID is init (1). If multiple processes are found via pgrep, returns only the first.
Takes the following directives:

=over

=item Name

Name of the process (to be used in the data set name, and on the filesystem-
proc_$name). Just in case you forget, any /'s will be converted to _'s before
being written to the filesystem.

=item Regex

Regex to use for matching the process. If this matches more than one process,
warnings will be thrown, as only the first is used. Update your regex to find
only one. If not specified, will be the same as the Name configuration.

=item Children

Boolean to indicate whether or not to gather statistics on the process's children.
Will recurss the child tree completely, getting stats on all. Defaults to 0.

=back

=head2 Example:

    <Plugin proc>
        Name     "sshd"
        Regex    "^/(usr/)?s?bin/sshd"
        Children true
    </Plugin>
    <Plugin processes>
        Name     "crond"
    </Plugin>

=head1 FUNCTIONS

=head2 proc_cfg

Config processing callback for Collectd.pm.

=head2 read_process

Collectd callback handler for reading data.

Registers the following datapoints per process:

=over

=item ps_processes

Number of processes currently running (parent process + its children).

=item ps_threads

Total thread count for all matched processes.

=item ps_openfiles

Number of open files for all matched processes.

=item ps_vmpeak

Aggregated peak virtual memory size (bytes) for all matched porcesses.

=item ps_vmsize

Total virtual memory size (bytes) for all matched processes.

=item ps_vmrss

Total resident set size (bytes) for all matched processes.

=item ps_vmhwm

Aggregated peak resident set size (bytes) for all matched processes.

=item ps_utime

Time spent performing user operations by all matched processes.
This value contains guest_time, as defined in "man proc".

=item ps_stime

Time spent performing system operations by all matched processes.

=item ps_iowait

Time spent waiting on IO for all matched processes.

=item ps_guest_time

Time spent performing guest operations by all matched processes.

=back

=head1 AUTHOR

Geoff Franks, C<< <geoff.franks at gmail.com> >>

=cut
