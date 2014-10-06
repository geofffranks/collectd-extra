#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::Collectd::Plugins typesdb => [ 'extra-types.db' ];

$ENV{TEST_COLLECTD_CPU} = "t/data/cpu/good";
load_ok "Collectd::Plugins::CPU";
read_ok "Collectd::Plugins::CPU", "cpu";

my @got = read_values "Collectd::Plugins::CPU", "cpu";
cmp_deeply \@got, [[{
		type   => 'cpu_user',
		plugin => 'cpu',
		values => [ 9306762 ],
	}], [{
		type   => 'cpu_nice',
		plugin => 'cpu',
		values => [ 93078 ],
	}], [{
		type   => 'cpu_system',
		plugin => 'cpu',
		values => [ 3351368 ],
	}], [{
		type   => 'cpu_idle',
		plugin => 'cpu',
		values => [ 1328869838 ],
	}], [{
		type   => 'cpu_iowait',
		plugin => 'cpu',
		values => [ 5459093 ],
	}], [{
		type   => 'cpu_irq',
		plugin => 'cpu',
		values => [ 208610 ],
	}], [{
		type   => 'cpu_softirq',
		plugin => 'cpu',
		values => [ 1 ],
	}], [{
		type   => 'cpu_steal',
		plugin => 'cpu',
		values => [ 2 ],
	}], [{
		type   => 'cpu_guest',
		plugin => 'cpu',
		values => [ 3 ],
	}], [{
		type   => 'cpu_guest_nice',
		plugin => 'cpu',
		values => [ 4 ],
	}]], "Retrieved data out of CPU correctly";

$ENV{TEST_COLLECTD_CPU} = "t/data/cpu/bad";
@got = read_values "Collectd::Plugins::CPU", "cpu";
cmp_deeply \@got, [], "read_cpu returns no values if can't parse stats";

delete $ENV{TEST_COLLECTD_CPU};
@got = read_values "Collectd::Plugins::CPU", "cpu";
cmp_deeply \@got, [[{
		type   => 'cpu_user',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_nice',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_system',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_idle',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_iowait',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_irq',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_softirq',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_steal',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_guest',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}], [{
		type   => 'cpu_guest_nice',
		plugin => 'cpu',
		values => [ re('\d+') ],
	}]], "read_cpu() appears to work on this system/kernel combo";

done_testing;
