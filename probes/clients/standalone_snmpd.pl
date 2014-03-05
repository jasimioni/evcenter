#!/usr/bin/perl

use FindBin qw/$RealBin/;
use File::Spec::Functions;
use lib catfile($RealBin, 'lib');

use EVCenter::Probe::Storer;
use EVCenter::Probe::SNMPParser;

BEGIN {
	eval "use EV"; # Use EV if Available to make AnyEvent Better
}

use common::sense;
use AnyEvent; BEGIN { AnyEvent::common_sense }
use IO::Socket;
use Scalar::Util ();
use Time::HiRes qw/tv_interval gettimeofday usleep/;
use Data::Dumper;
use Convert::ASN1;
use Try::Tiny;

use constant SNMPTRAPD_DEFAULT_PORT => 162;
use constant SNMPTRAPD_RFC_SIZE     => 484;   # RFC limit
use constant SNMPTRAPD_REC_SIZE     => 1472;  # Recommended size
use constant SNMPTRAPD_MAX_SIZE     => 65467; # Actual limit (65535 - IP/UDP)

my $asn = Convert::ASN1->new;
$asn->prepare(<<PDU_END);
    PDU ::= SEQUENCE {
        version   INTEGER,
        community STRING,
        pdu_type  PDUs
    }
    PDUs ::= CHOICE {
        response        Response_PDU,
        trap            Trap_PDU,
        inform_request  InformRequest_PDU,
        snmpv2_trap     SNMPv2_Trap_PDU
    }
    Response_PDU      ::= [2] IMPLICIT PDUv2
    Trap_PDU          ::= [4] IMPLICIT PDUv1
    InformRequest_PDU ::= [6] IMPLICIT PDUv2
    SNMPv2_Trap_PDU   ::= [7] IMPLICIT PDUv2

    IPAddress ::= [APPLICATION 0] STRING
    Counter32 ::= [APPLICATION 1] INTEGER
    Guage32   ::= [APPLICATION 2] INTEGER
    TimeTicks ::= [APPLICATION 3] INTEGER
    Opaque    ::= [APPLICATION 4] STRING
    Counter64 ::= [APPLICATION 6] INTEGER

    PDUv1 ::= SEQUENCE {
        ent_oid         OBJECT IDENTIFIER,
        agent_addr      IPAddress,
        generic_trap    INTEGER,
        specific_trap   INTEGER,
        timeticks       TimeTicks,
        varbindlist     VARBINDS
    }
    PDUv2 ::= SEQUENCE {
        request_id      INTEGER,
        error_status    INTEGER,
        error_index     INTEGER,
        varbindlist     VARBINDS
    }
    VARBINDS ::= SEQUENCE OF SEQUENCE {
        oid    OBJECT IDENTIFIER,
        value  CHOICE {
            integer   INTEGER,
            string    STRING,
            oid       OBJECT IDENTIFIER,
            ipaddr    IPAddress,
            counter32 Counter32,
            guage32   Guage32,
            timeticks TimeTicks,
            opaque    Opaque,
            counter64 Counter64,
            null      NULL
        }
    }
PDU_END
my $snmpasn = $asn->find('PDU');

my $host = '0.0.0.0';
my $port = 10162;

my $cv = AnyEvent->condvar;

my $server = IO::Socket::INET->new(
    LocalAddr => $host,
    LocalPort => $port,
    Proto     => 'udp',
    Blocking  => 0
) or croak "Socket could not be created: $!";

my $maxlen = SNMPTRAPD_MAX_SIZE;

my $t0 = [gettimeofday];
my $count = 0;

my %replies;
my $watcher = AnyEvent->io(
	fh   => $server,
	poll => 'r',
	cb   => sub {
		my $buf;
		my $remote_addr = $server->recv($buf, $maxlen);
		if (defined $remote_addr) {
			my ($port, $iaddr) = sockaddr_in($remote_addr);
			my $herstraddr = inet_ntoa($iaddr);
			try {
				my $trap = $snmpasn->decode($buf);
				if (! defined $trap) {
					die 'Error decoding PDU - ' . (defined($snmpasn->error) ? $snmpasn->error : "Unknown Convert::ASN1->decode() error\n");
				} 

			    if ($trap->{'version'} > 1) {
			        die 'Unrecognized SNMP version - ' . $trap->{'version'};
			    }

			    my %parsed_trap;
			    my $pdutype = sprintf "%s", keys(%{$trap->{'pdu_type'}});

			    ### Assemble decoded trap object
			    # Common
			    $parsed_trap{'version'} = $trap->{'version'};
			    $parsed_trap{'community'} = $trap->{'community'};
			    if ($pdutype eq 'trap') {
			        $parsed_trap{'pdu_type'} = 4

			    } elsif ($pdutype eq 'inform_request') {
			        $parsed_trap{'pdu_type'} = 6;

			        $trap->{'pdu_type'}{'response'} = delete $trap->{'pdu_type'}{'inform_request'};
			        my $buffer = $snmpasn->encode($trap);
			        if (!defined($buffer)) {
			        	die "Failed to send inform request confirmation";
			        }
			        $server->send($buffer, 0, $remote_addr);
			        $trap->{'pdu_type'}{'inform_request'} = delete $trap->{'pdu_type'}{'response'};
			        say "Replied Inform Request";
			    } elsif ($pdutype eq 'snmpv2_trap') {
			        $parsed_trap{'pdu_type'} = 7
			    }

			    # v1
			    if ($trap->{'version'} == 0) {
			        $parsed_trap{'ent_oid'}       =           $trap->{'pdu_type'}->{$pdutype}->{'ent_oid'};
			        $parsed_trap{'agent_addr'}    = inet_ntoa($trap->{'pdu_type'}->{$pdutype}->{'agent_addr'});
			        $parsed_trap{'generic_trap'}  =           $trap->{'pdu_type'}->{$pdutype}->{'generic_trap'};
			        $parsed_trap{'specific_trap'} =           $trap->{'pdu_type'}->{$pdutype}->{'specific_trap'};
			        $parsed_trap{'timeticks'}     =           $trap->{'pdu_type'}->{$pdutype}->{'timeticks'};

			    # v2c
			    } elsif ($trap->{'version'} == 1) {
			        $parsed_trap{'request_id'}   = $trap->{'pdu_type'}->{$pdutype}->{'request_id'};
			        $parsed_trap{'error_status'} = $trap->{'pdu_type'}->{$pdutype}->{'error_status'};
			        $parsed_trap{'error_index'}  = $trap->{'pdu_type'}->{$pdutype}->{'error_index'};
			    }

			    # varbinds
			    my @varbinds;
			    for my $i (0..$#{$trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}}) {
			        my %oidval;
			        for (keys(%{$trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}[$i]->{'value'}})) {
			            # defined
			            if (defined($trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}[$i]->{'value'}{$_})) {
			                # special cases:  IP address, null
			                if ($_ eq 'ipaddr') {
			                    $oidval{$trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}[$i]->{'oid'}} = inet_ntoa($trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}[$i]->{'value'}{$_})
			                } elsif ($_ eq 'null') {
			                    $oidval{$trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}[$i]->{'oid'}} = '(NULL)'
			                # no special case:  just assign it
			                } else {
			                    $oidval{$trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}[$i]->{'oid'}} = $trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}[$i]->{'value'}{$_}
			                }
			            # not defined - ""
			            } else {
			                $oidval{$trap->{'pdu_type'}->{$pdutype}->{'varbindlist'}[$i]->{'oid'}} = ""
			            }
			        }
			        push @varbinds, \%oidval
			    }
			    $parsed_trap{'varbinds'} = \@varbinds;
			    print Dumper \%parsed_trap;
			} catch {
				say "Error parsing trap: $_";
			};
		}
	},
);

say $cv->recv;

=head1 BORROWED CODE
	
B<Sample Code for UDP Server With AnyEvent>

	https://github.com/iizukanao/AnyEvent-UDPServer/blob/master/lib/AnyEvent/UDPServer.pm

B<SNMPv1, v2 Traps and Informs Decoding>

	http://search.cpan.org/~vinsworld/Net-SNMPTrapd-0.12/lib/Net/SNMPTrapd.pm


=cut