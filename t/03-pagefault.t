#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Deep;
use Test::Collectd::Plugins typesdb => [ 'extra-types.db' ];
use POSIX;

$ENV{TEST_COLLECTD_PAGEFAULT} = "t/data/pagefault/good";
load_ok "Collectd::Plugins::PageFault";
read_ok "Collectd::Plugins::PageFault", "pagefaults";

my @got = read_values "Collectd::Plugins::PageFault", "pagefaults";
cmp_deeply \@got, [[{
		type   => 'pf_pgpgin',
		plugin => 'pagefaults',
		values => [ 12925748 ],
	}], [{
		type   => 'pf_pgpgout',
		plugin => 'pagefaults',
		values => [ 290870453 ],
	}], [{
		type   => 'pf_pgfault',
		plugin => 'pagefaults',
		values => [ 4121084040 ],
	}], [{
		type   => 'pf_pgmajfault',
		plugin => 'pagefaults',
		values => [ 23977 ],
	}]], "Retrieved data out of vmstat correctly";

$ENV{TEST_COLLECTD_PAGEFAULT} = "t/data/pagefault/bad";
@got = read_values "Collectd::Plugins::PageFault", "pagefaults";
cmp_deeply \@got, [], "read_vmstat returns no values if can't parse stats";

delete $ENV{TEST_COLLECTD_PAGEFAULT};
@got = read_values "Collectd::Plugins::PageFault", "pagefaults";
cmp_deeply \@got, [[{
		type   => 'pf_pgpgin',
		plugin => 'pagefaults',
		values => [ re('\d+') ],
	}], [{
		type   => 'pf_pgpgout',
		plugin => 'pagefaults',
		values => [ re('\d+') ],
	}], [{
		type   => 'pf_pgfault',
		plugin => 'pagefaults',
		values => [ re('\d+') ],
	}], [{
		type   => 'pf_pgmajfault',
		plugin => 'pagefaults',
		values => [ re('\d+') ],
	}]], "read_vmstat() appears to work on this system/kernel combo";

done_testing;
