#!/usr/bin/perl
use strict;
use warnings;

my $file = shift or die "Usage: $0 <classfile> <offset> <length>\n";
my $offset = shift;
my $len = shift;

open my $fh, '<', $file or die "Cannot open $file: $!\n";
binmode $fh;
seek $fh, $offset, 0;
read $fh, my $data, $len;
close $fh;

for (my $i = 0; $i < length($data); $i++) {
    printf "%04x: %02x\n", $i, ord(substr($data, $i, 1));
}
