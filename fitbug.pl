#!/usr/bin/perl5.10.0

use strict;
use warnings;

use Getopt::Long;
use Data::Dumper;
use FitBug;

my %options = ();
my $result = GetOptions(
    \%options,
    "username=s",
    "password=s",
    "action:s",
    "args:s@"
    );

my %calls = (
    'getmeals' => {
        argsize => 1,
        argmsg  => "Time of day",
        call => \&FitBug::mymeals,
    },
    'addmeal' => {
        argsize => 3,
        argmsg  => "Time of day, mealid, amount",
        call => \&FitBug::addmeal,
        defaults => { 2 => 1},
    }
    );

my $plan = setup(%options);
if(scalar @{$options{args}} != $call->{argsize}) {
    find_args($plan);
#    die "Wrong number of arguments passed to $options{action}, required: $call->{argmsg}";
}


# ==================================================

FitBug::login($options{username}, $options{password});

my $output = $call->{call}->(@{$options{args}});
print Dumper($output);

# ====================================================

sub find_args {
    my ($plan) = @_;
}

sub setup {
    my (%options) = @_;

## Make optional, fetch from file?
#if(!$options{username} || !$options{password}) {
#    die "Please pass your Fitbug username and password";
#}

    if(!$result || !exists $options{args} ) {
        die "Usage: $0 --action=(getmeals|addmeal) --username=<fitbuguser> --password=<fitbugpasswd> --args=<args for chosen action>";
    }

## Argument "action" must be a valid call (default to add meal)
## Args must contain a valid number of parameters

    $options{action} ||= 'addmeal';
    my $call = $calls{$options{action}};
    if(!$call) {
        die "$options{action} is not a valid action; supported actions: ", join(',', keys %calls);
    }
    
## Set defaults:
    foreach my $ind (0..$call->{argsize)-1) {
        if(!exists $options{args}[$ind] && defined($call->{defaults}{$ind}) ) {
            $options{args}[$ind] = $call->{defaults}{$ind};
        }
    }

    return { call => $call, opts => \%options };
}
