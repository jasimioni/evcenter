#!/usr/bin/perl

use JSON::RPC::Client;
use Data::Dumper;

my $client = new JSON::RPC::Client;
my $url    = 'http://localhost:3000/WebServices';

my $auth = shift;

$callobj = {
    method  => 'event.get',
    params  => { columns => [ node ] },
    jsonrpc => '2.0',
    auth    => $auth,
    id      => 'get events'
};

$res = $client->call($url, $callobj);

if($res) {
	if ($res->is_error) {
	    die "Error Code: " . $res->error_message->{code} . "\nError Message: " . $res->error_message->{message} . "\n" ;
	} else {
        print Dumper $res->result;
    }
} else {
	die "Fail to connect to WebService: " . $client->status_line . "\n";
}
