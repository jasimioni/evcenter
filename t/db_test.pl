#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use lib '../lib';

use EVCenter::Base::Event;

my $ev = EVCenter::Base::Event->new();

my $rows = $ev->get_events(filter   => { type => { -in => [ 1, 2 ] } },
                           restrict => { node => { -like => '%' }},
                           order_by => [ '-type', 'node' ]
                       );

#my $rows = $ev->get_events();
print "Erro consultando: ", $ev->errstr, "\n" if ($ev->errstr);

my $count = @$rows;

print "Returned $count events\n";

print Dumper($rows);

my $rowcount = $ev->upd_events(filter => { node => 'svlxger1' }, update => { suppression => 1 }, restrict => { type => { -in => [1, 2] } });
print "Erro atualizando: ", $ev->errstr, "\n" if ($ev->errstr);

print "Updated $rowcount rows\n";
