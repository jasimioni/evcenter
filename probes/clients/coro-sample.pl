#!/usr/bin/perl

use common::sense;
use Coro;
$| = 1;

my $i = 1;

foreach my $number (1..300) {
	async {
		while (1) {
			say "I'm process $number $i";
			$i++;
			cede;
		}	
	};
}

say "Am I the main process?";
schedule;
