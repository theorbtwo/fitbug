#!/usr/bin/perl5.10.0

use strict;
use warnings;

use Getopt::Long;
use Term::Prompt;
use Data::Dumper;
use FitBug;

my %options = ();
my $result = GetOptions(
                        \%options,
                        "username=s",
                        "password=s",
                        "mealtime:s",
                       );

my $food = shift;
if(!$result || !$food) {
    die "Usage: $0 --username=<fitbuguser> --password=<fitbugpasswd> [--mealtime={breakfast|lunch|dinner}] <search term>";
}

print "Looking for $food\n";

FitBug::login($options{username}, $options{password});

my $foods = find_food($food);

if(@$foods > 1) {
    ## choose your fate
    $foods = prompt_filter($foods);
}

if(@$foods) {
    print "Adding '$foods->[0]{desc}' to $foods->[0]{sect}\n";
    FitBug::addmeal($foods->[0]{sect}, $foods->[0]{foundin}, $foods->[0]{id}, 1);
} else {
    print "No matches found. Giving up.\n";
}



# ===================================================

sub find_food {
    my ($search_arg) = @_;

    my $matches = [];
    foreach my $mealtime (qw/breakfast lunch dinner snacks/) {
        my $meals = FitBug::mymeals($mealtime);
#        print Dumper($meals);
        while (my ($mealid, $mealdesc) = each (%$meals)) {
            ## $food may contain regex chars, this is on purpose.
            if($mealdesc =~ /$food/i) {
                push @$matches, { sect => $mealtime, 
                                  id => $mealid,
                                  desc => $mealdesc,
                                  foundin => 'meal',
                };
            }
        }

    }

    ## all mealtimes have the same favourites
    my $mealtime = 'snacks';
    my $favourites = FitBug::favourites($mealtime);
    while (my ($mealid, $mealdesc) = each (%$favourites)) {
      ## $food may contain regex chars, this is on purpose.
      if($mealdesc =~ /$food/i) {
        push @$matches, { sect => $mealtime, 
                          id => $mealid,
                          desc => $mealdesc,
                          foundin => 'fav',
                        };
      }
    }

    print Dumper($matches);
    return $matches;
}

sub prompt_filter {
    my ($items) = @_;

    print "Found ", scalar(@$items), " matching items.\n";
    
    my $match = prompt('m', 
                       { 
                           prompt => 'Pick one:',
                           title => 'Found matches',
                           items => [ map { $_->{desc} } @$items ],
                           accept_empty_selection => 1,
                       },
                       '', undef);
    print "You picked: $match\n";
    if(!defined $match) {
        print "Empty selection\n";
        return [];
    }

    my $found = $items->[$match];
    print "Filtered: ", Dumper($found);

    return [ $found ];
}
