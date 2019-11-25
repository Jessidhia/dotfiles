#! /usr/bin/env perl

use strict;
use IO::Handle;

exit 0 unless @ARGV;

my $exe = shift;

unless (-f $exe) {
    STDERR->say("command not found: $exe");
    exit -1;
}

my $path_cmd = "cygpath";
my @args = ($exe);

if ($^O ne "cygwin") {
    $path_cmd = "winepath";
    unshift @args, "wine"
}

for my $f (@ARGV) {
    if ($f eq '/dev/null') { # cygpath would return \\.\NUL, which isn't wrong,
        $f = 'NUL';          # but might cause issues with code that checks for NUL
    } elsif ($f =~ m!^-!) {
        ;                    # if your file really starts with a -, use ./
    } elsif (-f $f) {
        open(my $p, '-|', $path_cmd, qw{-wl --}, $f);
        $f = <$p>;
        close($p);
        chomp $f;
    }
    push @args, $f
}

exec {$args[0]} @args;
