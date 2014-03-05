#!/usr/bin/perl

use JSON::RPC::Client;
use Data::Dumper;

my $auth = shift;

my $client = new JSON::RPC::Client;
my $url    = 'http://localhost:3000/WebServices';

my $callobj = {
	method  => 'event.add',
	params  => [ 
			{ node => 'perl-tester1', message => 'Test Event Inserted', dedup_id => 'test-event-1', event_id => 'test-event-1', type => 1, severity => 1 },
			{ node => 'perl-tester2', message => 'Test Event Inserted', dedup_id => 'test-event-2', event_id => 'test-event-2', type => 1, severity => 2 },
			{ node => 'perl-tester3', message => 'Test Event Inserted', dedup_id => 'test-event-3', event_id => 'test-event-3', type => 1, severity => 3 },
			{ node => 'perl-tester4', message => 'Test Event Inserted', dedup_id => 'test-event-4', event_id => 'test-event-4', type => 1, severity => 4 },
 		], 
	jsonrpc => '2.0',
	id 	=> 'Insert Event Test',
	auth	=> $auth,
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
