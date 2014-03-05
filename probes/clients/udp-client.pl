#!/usr/bin/perl

use common::sense;
use IO::Socket::INET;
use Time::HiRes qw/usleep tv_interval gettimeofday/;

$| = 1;

my ($socket, $data);

#  We call IO::Socket::INET->new() to create the UDP Socket 
# and bind with the PeerAddr.
#send operation

my $i = 1;
my $data;
my $buf;
my $maxlen = 1472;

my $t0 = [gettimeofday];
my $elapsed;

$socket = new IO::Socket::INET (
	PeerAddr   => '127.0.0.1:10162',
	Proto        => 'udp'
) or die "ERROR in Socket Creation : $!\n";

my $pid = $$;
$data = "x" x $ARGV[0];
my $i = 1;
$socket->send($i++ . ": $data");
