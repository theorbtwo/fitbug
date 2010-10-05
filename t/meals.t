#!/usr/bin/perl5.10.0

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Data::Dumper;

use_ok('FitBug');

dies_ok(sub { FitBug::login('castaway', 'foo') }, 'Dies on incorrect password');
my $ret = FitBug::login('castaway', '131.Nem');
ok($ret, 'Logged in');

my $breakfasts = FitBug::mymeals('breakfast');
ok(keys %$breakfasts, 'Found stored breakfasts');
my $breakfast = FitBug::getmeal('breakfast', (keys %$breakfasts)[0]);
ok($breakfast, 'Got first breakfast');
FitBug::addmeal('breakfast', (keys %$breakfasts)[0]);

my $sidebar = FitBug::sidebar();
ok($sidebar, 'Got sidebar data');
# print Dumper($sidebar);
