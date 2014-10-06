#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::MockModule;
use Test::Collectd::Plugins typesdb => [ 'extra-types.db' ];
use POSIX;

load_ok "Collectd::Plugins::Process";
my $mock = Test::MockModule->new("Collectd::Plugins::Process");
$mock->mock(get_pid      => sub { return 1234 });
$mock->mock(get_children => sub { return (4321, 2345) });
$ENV{TEST_PROC_STATUS} = "t/data/processes/status";
$ENV{TEST_PROC_STAT}   = "t/data/processes/stat";
$ENV{TEST_PROC_FD}     = "t/data/processes/fd";
my @data = read_values "Collectd::Plugins::Process", "proc", "t/data/processes/test.conf";
cmp_deeply \@data, bag([{
		#### Collectd has 2 child pids, for 3 stat retrievals
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_utime',
		'values' => [
			3431 * 3 / CLOCKS_PER_SEC
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_stime',
		'values' => [
			6543 * 3 / CLOCKS_PER_SEC
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_guest_time',
		'values' => [
			134 * 3 / CLOCKS_PER_SEC
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_iowait',
		'values' => [
			130 * 3 / CLOCKS_PER_SEC
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_processes',
		'values' => [
			1 * 3
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_threads',
		'values' => [
			20 * 3
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_openfiles',
		'values' => [
			10 * 3
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_vmpeak',
		'values' => [
			31032 * 1024 * 3
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_vmsize',
		'values' => [
			31028 * 1024 * 3
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_vmrss',
		'values' => [
			816 * 1024 * 3
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'collectd',
		'type' => 'ps_vmhwm',
		'values' => [
			817 * 1024 * 3
		],
	}], [{ ### sshd has only one pid
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_utime',
		'values' => [
			3431 / CLOCKS_PER_SEC
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_stime',
		'values' => [
			6543 / CLOCKS_PER_SEC
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_iowait',
		'values' => [
			130 / CLOCKS_PER_SEC
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_guest_time',
		'values' => [
			134 / CLOCKS_PER_SEC
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_processes',
		'values' => [
			1
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_threads',
		'values' => [
			20
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_openfiles',
		'values' => [
			10
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_vmpeak',
		'values' => [
			31032 * 1024
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_vmsize',
		'values' => [
			31028 * 1024
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_vmrss',
		'values' => [
			816 * 1024
		],
	}], [{
		'plugin' => 'proc',
		'plugin_instance' => 'sshd',
		'type' => 'ps_vmhwm',
		'values' => [
			817 * 1024
		],
	}]), "Resultant data is correct"
	or diag explain \@data;


done_testing;
