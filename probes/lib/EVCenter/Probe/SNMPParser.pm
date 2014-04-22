package EVCenter::Probe::SNMPParser;

use common::sense;
use Moose;
use Carp qw/carp croak/;
use Socket;
use Convert::ASN1;
use Try::Tiny;

has asn     => (is => 'ro', isa => 'Object', default => sub { Convert::ASN1->new });
has snmpasn => (is => 'ro', isa => 'Object', builder => '_build_snmpasn');
has error   => (is => 'rw', isa => 'Str');

=encoding utf8

=head1 NAME

EVCenter::Probe::SNMPParser - Class to decode SNMPv1 Traps, SNMPv2 Traps and Informs

=head1 SYNOPSIS

    use EVCenter::Probe::SNMPParser;
    $parser = EVCenter::Probe::SNMPParser->new;

    $decoded_pdu = $parser->decode($datagram) or warn $parser->error;
    if ($decoded_pdu->{pdu_type} == 6) {
        $parser->inform_reply({ socket => $socket, 
                                inform_request => $decoded_pdu, 
                                remote_addr => $remote_addr 
                              }) or warn $parser->error;
    }

    # Where $socket is a IO::Socket::INET object and $remote_addr 
    # the return of $socket->recv;

=head1 DESCRIPTION

This class is used to decode SNMP Traps (v1 and v2) and provide a hash_ref
containing the information from it. It also allows the reply of inform
requests.

=head1 METHODS
=cut

# snmpasn object builder - this one has the ASN1 format of a
# the needed SNMP PDUs.
sub _build_snmpasn {
	my $self = shift;

	$self->{asn}->prepare(<<PDU_END);
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
	$self->{snmpasn} = $self->{asn}->find('PDU');
	return $self->{snmpasn};
} 

=head2 decode

This method will receive a binary data (UDP Datagram, usually read 
from a $socket->recv), parse it using ASN1 Rules and return a hash_ref 
with the decoded data or undef on failure.

    use Data::Dumper;
    my $decoded_pdu = $parser->decode($datagram);
    print Dumper $decoded_pdu;


=cut

sub decode {
	my $self     = shift;
	my $datagram = shift;
	try {
		my $trap = $self->{snmpasn}->decode($datagram);
		if (! defined $trap) {
			die 'Error decoding PDU - ' . (defined($self->{snmpasn}->error) ? $self->{snmpasn}->error : "Unknown Convert::ASN1->decode() error\n");
		} 

	    if ($trap->{'version'} > 1) {
	        die 'Unrecognized SNMP version - ' . $trap->{'version'};
	    }

	    my %parsed_trap;
	    $parsed_trap{original_trap} = $trap;
	    my $pdutype = sprintf "%s", keys(%{$trap->{'pdu_type'}});

	    ### Assemble decoded trap object
	    # Common
	    $parsed_trap{'version'} = $trap->{'version'} + 1;
	    $parsed_trap{'community'} = $trap->{'community'};
	    if ($pdutype eq 'trap') {
	        $parsed_trap{'pdu_type'} = 4

	    } elsif ($pdutype eq 'inform_request') {
	        $parsed_trap{'pdu_type'} = 6;

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
            # Original Code - Replaced
	        # push @varbinds, \%oidval
            my ($key, $value) = %oidval;
            push @varbinds, { oid => $key, value => $value };
	    }
	    $parsed_trap{'varbinds'} = \@varbinds;
	    return \%parsed_trap;
	} catch {
		 $self->error("Error parsing trap: $_");
		 return undef;
	};
}

=head2 inform_reply

It will send a I<Response-PDU> to reply an I<InformRequest-PDU>. 
It must receive a hash_ref containing a decoded_pdu and a socket
which will be used to reply. Optionally a remote_addr can be informed
(if not, it will reply to the last received source) - see C<IO::Socket> 
on that.

It will return 1 on success or 0 on failure.

    if ($decoded_pdu->{pdu_type} == 6) {
        $parser->inform_reply({ socket => $socket, 
                                inform_request => $decoded_pdu, 
                                remote_addr => $remote_addr 
                              }) or warn $parser->error;
    }    

=cut

sub inform_reply {
	my $self = shift;
	my $p    = shift;

	try {
		my $inform_request = $p->{inform_request}->{original_trap};
		my $socket         = $p->{socket};
		my $remote_addr    = $p->{remote_addr};

	    $inform_request->{'pdu_type'}{'response'} = delete $inform_request->{'pdu_type'}{'inform_request'};
	    my $datagram = $self->{snmpasn}->encode($inform_request);
	    if (!defined($datagram)) {
	    	die "Failed to send inform request confirmation";
	    }
	    $socket->send($datagram, 0, $remote_addr);
	    $inform_request->{'pdu_type'}{'inform_request'} = delete $inform_request->{'pdu_type'}{'response'};
	    return 1;
	} catch {
		$self->error("Failed to reply inform: $_");
		return 0;
	}

}

=head1 SEE ALSO

L<IO::Socket>, L<Convert::ASN1>, L<Net::SNMPTrapd>

L<Net::SNMPTrapd> was used as a reference to write this code.

=head1 AUTHOR

Joao Andre Simioni <jasimioni@gmail.com>

=head1 LICENSE

TBD

=cut
1;
