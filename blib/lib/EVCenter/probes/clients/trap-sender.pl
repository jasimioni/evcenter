#!/usr/bin/perl

use common::sense;
use Net::SNMP qw(:ALL);

my ($session, $error) = Net::SNMP->session(
   -hostname  => 'localhost',
   -community => 'public',
   -port      => 10162,      # Need to use port 162 
   -version   => '1',
);

if (!defined($session)) {
   printf("ERROR: %s.\n", $error);
   exit 1;
}

my $result;
my $int = 1;
while (1) {
$result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => '10.10.1.1',
   -generictrap  => 6,
   -specifictrap => 1005,
   -timestamp    => 12363000,
   -varbindlist  => [
      '1.3.6.1.2.1.1.1.0', INTEGER, $int++,
      '1.3.6.1.2.1.1.5.0', OCTET_STRING, 'Closet Hub' 
   ]
);
	print "Sent $int events\n" if (! ($int % 500));
}

if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("Trap-PDU sent.\n");
}
