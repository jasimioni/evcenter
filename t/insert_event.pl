#!/usr/bin/perl

use JSON::RPC::Client;
use Data::Dumper;

my $client = new JSON::RPC::Client;
my $url    = 'http://localhost:3000/WebServices';

my $callobj = {
	method  => 'event.add',
	params  => [ 
			{ node => 'perl-tester1', message => 'Test Event Inserted', dedup_id => 'test-event-1', 
			  event_id => 'test-event-1', type => 1, severity => 3 },
			{ node => 'perl-tester2', message => 'Test Event Inserted', dedup_id => 'test-event-2', 
			  event_id => 'test-event-2', type => 1, severity => 4 },
 		], 
	jsonrpc => '2.0',
	id 	=> 'Insert Event Test',
};

my $res = $client->call($url, $callobj);

if($res) {
	print "=========== Response =============\n", Dumper($res), "===========================\n";
	if ($res->is_error) {
		print "Error Code: ", $res->error_message->{code}, 
		      "\nError Message: ", $res->error_message->{message}, "\n";
	} else {
		print "########## Success ########:\n", Dumper $res->result;
	}
} else {
	print "Fail to connect to WebService: ", $client->status_line, "\n";
}
