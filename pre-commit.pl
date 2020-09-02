#!/usr/bin/env perl

use strict;
use warnings;
use Term::ANSIColor;

use constant HOOK_NAME => 'multi-email';
my %mm_config;

# match_url finds an email address configured for
# a given remote.
# If a match is found it is written to local git config.
sub match_url {
    my ($remote, $url) = @_;

    foreach my $org (sort keys %mm_config) {
        if ($url =~ /$mm_config{$org}{match}/) {
            # skip if no email address is configures for this
            # organization.
            next if (not exists($mm_config{$org}{email}));

            my $match_email = "$mm_config{$org}{email}";
            print color('yellow');
            print("Setting local user.email = $match_email\n",
                "Commit again if this is correct.");
            print color('reset');

            # write user.email to local git config file
            system("git config --local user.email $match_email");
            exit (1);
        }
    }
}

# If local user.email is already set we are done.
system("git config --local user.email >/dev/null") || exit (0);

# Get all multi-email sections from git config.
my @git_config = split /\n/, `git config --global --list`;
foreach my $line( @git_config ) {
    if ($line =~ m/^${\HOOK_NAME}\.(\w+)\.(email|match)=(.+)$/) {
        $mm_config{$1}{$2}=$3;
    }
}

# get all remotes. Try matching for the remote
# 'origin' immediatly if found. Store the rest
# to try matching later.
my @remotes_list = split /\n/, `git remote -v`;
my @remotes;
foreach my $line( @remotes_list ) {
    if ($line =~ m/^(\w+)\s+(.+)$/) {
        if( $1 eq 'origin' ) {
            match_url($1,$2);
        }
        push @remotes, $2;
    }
}

# try to match any remote if origin did
# not produce a match
foreach my $remote( @remotes ) {
    match_url($1,$remote)
}

# No matches were found. Global user.email will be used.
exit (0);