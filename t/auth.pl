#!/usr/bin/perl

use JSON::RPC::Client;
use Data::Dumper;

my $client = new JSON::RPC::Client;
my $url    = 'http://localhost:3000/WebServices';

my $callobj = {
	method  => 'auth',
	params  => { username => 'jsimioni', password => 'oss' }, 
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
