#!/usr/bin/perl

use lib '../lib';
use common::sense;
use EVCenter::Base::Event::Processor;
use Data::Dumper;
use Log::Any::Adapter ('Stdout');

my $processor = EVCenter::Base::Event::Processor->new;

print join(", ", keys %{$processor->drivers}), "\n";;

my $event =  {
          'probe_hostname' => 'evcenter',
          'error_index' => 0,
          'version' => 2,
          'probe_type' => 'SNMPd',
          'probe_id' => 'probe_snmpd',
          'original_trap' => {
                             'community' => 'public',
                             'version' => 1,
                             'pdu_type' => {
                                             'inform_request' => {
                                                                   'error_status' => 0,
                                                                   'error_index' => 0,
                                                                   'varbindlist' => [
                                                                                      {
                                                                                        'value' => {
                                                                                                     'timeticks' => 12363000
                                                                                                   },
                                                                                        'oid' => '1.3.6.1.2.1.1.3.0'
                                                                                      },
                                                                                      {
                                                                                        'value' => {
                                                                                                     'oid' => '1.3.6.1.4.1.1010.5.0.3'
                                                                                                   },
                                                                                        'oid' => '1.3.6.1.6.3.1.1.4.1.0'
                                                                                      },
                                                                                      {
                                                                                        'value' => {
                                                                                                     'string' => 'Hub'
                                                                                                   },
                                                                                        'oid' => '1.3.6.1.2.1.1.1.0'
                                                                                      },
                                                                                      {
                                                                                        'value' => {
                                                                                                     'string' => 'Closet Hub'
                                                                                                   },
                                                                                        'oid' => '1.3.6.1.2.1.1.5.0'
                                                                                      }
                                                                                    ],
                                                                   'request_id' => 1609182582
                                                                 }
                                           }
                           },
          'source_address' => '127.0.0.1',
          'community' => 'public',
          'error_status' => 0,
          'timestamp' => '1395627671.10449',
          'pdu_type' => 6,
          'varbinds' => [
                          {
                            'value' => 12363000,
                            'key' => '1.3.6.1.2.1.1.3.0'
                          },
                          {
                            'value' => '1.3.6.1.4.1.1010.5.0.3',
                            'key' => '1.3.6.1.6.3.1.1.4.1.0'
                          },
                          {
                            'value' => 'Hub',
                            'key' => '1.3.6.1.2.1.1.1.0'
                          },
                          {
                            'value' => 'Closet Hub',
                            'key' => '1.3.6.1.2.1.1.5.0'
                          }
                        ],
          'request_id' => 1609182582
        };

$processor->process_event($event);

__END__


my $event = {
    probe_id      => 'Tester',
    probe_type    => 'SNMPd',
    enterprise    => '1.3.6.1.4.1.3939',
    oids          => {
        1 => 'Um',
        2 => 'Dois',
    },
    generic_trap  => 6,
    specific_trap => 15, 
};
