#!/usr/bin/perl

use JSON::RPC::Client;
use Data::Dumper;

my $client = new JSON::RPC::Client;
my $url    = 'http://192.168.0.120:3000/WebServices/AddEvent/To/Something';

my $callobj = {
	method  => 'event.del',
	params  => { a => 17, b => 25 }, # ex.) params => { a => 20, b => 10 } for JSON-RPC v1.1
	jsonrpc => '2.0',
	version => '2.0',
	id 	=> 'TESTE DE JSON',
};

my $res = $client->call($url, $callobj);

print Dumper $res;

if($res) {
	if ($res->is_error) {
		print "Error : ", $res->error_message, "\n";
	}
	else {
		print Dumper $res->result;
	}
}
else {
	print $client->status_line;
}
