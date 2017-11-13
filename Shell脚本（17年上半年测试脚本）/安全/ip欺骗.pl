#!/usr/bin/perl -w
use NET::RAWIP;
use strict;
my $src=$ARGV[0] or $usage();
my $dst=$ARGV[1] or $usage();
my $dst=$ARGV[2] or $usage();
my $rawpkt= new Net::RAWIP({
    ip => {
        saddr => $src,
        daddr => $dst
    },
    udp => {}}




)