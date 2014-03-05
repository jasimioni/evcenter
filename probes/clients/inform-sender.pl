#!/usr/bin/perl

use common::sense;
use Net::SNMP qw(:ALL);

my ($session, $error) = Net::SNMP->session(
   -hostname  => 'localhost',
   -community => 'public',
   -port      => 10162,      # Need to use port 162 
   -version   => '2c',
);

if (!defined($session)) {
   printf("ERROR: %s.\n", $error);
   exit 1;
}

my $result;
my $result = $session->inform_request(
   -varbindlist  => [
      '1.3.6.1.2.1.1.3.0', TIMETICKS, 12363000,
      '1.3.6.1.6.3.1.1.4.1.0', OBJECT_IDENTIFIER, '1.3.6.1.4.1.1010.5.0.3',
      '1.3.6.1.2.1.1.1.0', OCTET_STRING, 'Hub',
      '1.3.6.1.2.1.1.5.0', OCTET_STRING, 'Closet Hub' 
   ]
);

if (!defined($result)) {
   printf("ERROR: %s.\n", $session->error());
} else {
   printf("Trap-PDU sent.\n");
}
