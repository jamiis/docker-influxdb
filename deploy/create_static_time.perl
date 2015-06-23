#!/usr/bin/perl -w
use strict;use Time::Piece;my $time = Time::Piece->strptime("20090527", "%Y%m%d");utime $time, $time, @ARGV;