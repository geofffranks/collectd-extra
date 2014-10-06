use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Collectd::Extra',
    license             => 'gpl3',
    dist_author         => q{Geoff Franks <geoff.franks@gmail.com>},
    dist_version_from   => 'lib/Collectd/Extra.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    add_to_cleanup     => [ 'Collectd-Extra-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
