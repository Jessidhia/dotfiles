#! /usr/bin/env perl

use common::sense;
use IO::Handle;
use File::Which;

exit 0 unless @ARGV;

my $path_cmd = $^O eq "cygwin" ? "cygpath" : "winepath";

my $exe = shift;

$exe = which($exe) unless -f $exe;

unless (-f $exe) {
    STDERR->say("command not found: $exe");
    exit -1;
}

my @args = ($exe);

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
