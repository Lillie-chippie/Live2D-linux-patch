#!/usr/bin/perl
use strict;
use warnings;

my $file = shift or die "Usage: $0 <classfile>\n";
open my $fh, '<', $file or die "Cannot open $file: $!\n";
binmode $fh;

read $fh, my $magic, 4;
read $fh, my $version, 4;
read $fh, my $cp_count_raw, 2;
my $cp_count = unpack('n', $cp_count_raw);

print "Constant Pool Count: $cp_count\n";

for (my $i = 1; $i < $cp_count; $i++) {
    read $fh, my $tag_raw, 1;
    my $tag = unpack('C', $tag_raw);
    printf "%4d: Tag %2d ", $i, $tag;
    if ($tag == 1) { # UTF8
        read $fh, my $len_raw, 2;
        my $len = unpack('n', $len_raw);
        read $fh, my $data, $len;
        print "UTF8: $data\n";
    } elsif ($tag == 3 || $tag == 4) { # Integer, Float
        read $fh, my $data, 4;
        print "Int/Float\n";
    } elsif ($tag == 5 || $tag == 6) { # Long, Double
        read $fh, my $data, 8;
        print "Long/Double\n";
        $i++; # Takes two slots
    } elsif ($tag == 7) { # Class
        read $fh, my $data, 2;
        print "Class index: ", unpack('n', $data), "\n";
    } elsif ($tag == 8) { # String
        read $fh, my $data, 2;
        print "String index: ", unpack('n', $data), "\n";
    } elsif ($tag == 9 || $tag == 10 || $tag == 11) { # Fieldref, Methodref, InterfaceMethodref
        read $fh, my $data, 4;
        print "Ref\n";
    } elsif ($tag == 12) { # NameAndType
        read $fh, my $data, 4;
        print "NameAndType\n";
    } elsif ($tag == 15) { # MethodHandle
        read $fh, my $data, 3;
        print "MethodHandle\n";
    } elsif ($tag == 16) { # MethodType
        read $fh, my $data, 2;
        print "MethodType\n";
    } elsif ($tag == 17 || $tag == 18) { # Dynamic, InvokeDynamic
        read $fh, my $data, 4;
        print "Dynamic\n";
    } elsif ($tag == 19 || $tag == 20) { # Module, Package
        read $fh, my $data, 2;
        print "Module/Package\n";
    } else {
        print "Unknown tag $tag at index $i\n";
        last;
    }
}
close $fh;
