#!/usr/bin/perl
use strict;
use warnings;

my $file = $ARGV[0];
open(my $fh, '<', $file) or die "Cannot open $file: $!";
binmode($fh);

read($fh, my $magic, 4);
read($fh, my $minor, 2);
read($fh, my $major, 2);

read($fh, my $cp_count_raw, 2);
my $cp_count = unpack('n', $cp_count_raw);

my @cp;
for (my $i = 1; $i < $cp_count; $i++) {
    read($fh, my $tag_raw, 1);
    my $tag = unpack('C', $tag_raw);
    if ($tag == 1) { # UTF8
        read($fh, my $len_raw, 2);
        my $len = unpack('n', $len_raw);
        read($fh, my $val, $len);
        $cp[$i] = $val;
    } elsif ($tag == 7 || $tag == 8 || $tag == 16 || $tag == 19 || $tag == 20) {
        read($fh, my $dummy, 2);
    } elsif ($tag == 3 || $tag == 4 || $tag == 9 || $tag == 10 || $tag == 11 || $tag == 12 || $tag == 17 || $tag == 18) {
        read($fh, my $dummy, 4);
    } elsif ($tag == 5 || $tag == 6) {
        read($fh, my $dummy, 8);
        $i++;
    }
}

read($fh, my $access_flags, 2);
read($fh, my $this_class, 2);
read($fh, my $super_class, 2);

read($fh, my $interfaces_count_raw, 2);
my $interfaces_count = unpack('n', $interfaces_count_raw);
read($fh, my $interfaces, 2 * $interfaces_count);

read($fh, my $fields_count_raw, 2);
my $fields_count = unpack('n', $fields_count_raw);
for (my $i = 0; $i < $fields_count; $i++) {
    read($fh, my $f_access, 2);
    read($fh, my $f_name_idx, 2);
    read($fh, my $f_desc_idx, 2);
    read($fh, my $f_attr_count_raw, 2);
    my $f_attr_count = unpack('n', $f_attr_count_raw);
    print "Field: " . ($cp[$f_name_idx] // "???") . " Desc: " . ($cp[$f_desc_idx] // "???") . "\n";
    for (my $j = 0; $j < $f_attr_count; $j++) {
        read($fh, my $a_name_idx, 2);
        read($fh, my $a_len_raw, 4);
        my $a_len = unpack('N', $a_len_raw);
        read($fh, my $a_data, $a_len);
    }
}

read($fh, my $methods_count_raw, 2);
my $methods_count = unpack('n', $methods_count_raw);
for (my $i = 0; $i < $methods_count; $i++) {
    read($fh, my $m_access, 2);
    read($fh, my $m_name_idx_raw, 2);
    my $m_name_idx = unpack('n', $m_name_idx_raw);
    read($fh, my $m_desc_idx_raw, 2);
    my $m_desc_idx = unpack('n', $m_desc_idx_raw);
    print "Method: " . ($cp[$m_name_idx] // "???") . " Desc: " . ($cp[$m_desc_idx] // "???") . "\n";
    read($fh, my $m_attr_count_raw, 2);
    my $m_attr_count = unpack('n', $m_attr_count_raw);
    for (my $j = 0; $j < $m_attr_count; $j++) {
        read($fh, my $a_name_idx, 2);
        read($fh, my $a_len_raw, 4);
        my $a_len = unpack('N', $a_len_raw);
        read($fh, my $a_data, $a_len);
    }
}
close($fh);
