#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use JSON;
use Data::Dumper;

# Configuration
my $base_url = 'http://127.0.0.1:3000';
my $username = 'probe';
my $password = 'snmp';

# Initialize the UserAgent
my $ua = LWP::UserAgent->new( timeout => 10 );
my $json_codec = JSON->new->utf8;

print "=== Step 1: Authenticating ===\n";

# Construct the Auth payload matching your _authenticate method
my $auth_payload = {
    method  => 'auth',
    params  => { username => $username, password => $password },
    jsonrpc => '2.0',
    id      => "Process $$ Authentication at " . time,
};

my $auth_req = POST(
    "$base_url/WebServices",
    Content_Type => 'application/json',
    Content      => $json_codec->encode($auth_payload)
);

my $auth_res = $ua->request($auth_req);

if (!$auth_res->is_success) {
    die "Authentication HTTP Request Failed: " . $auth_res->status_line . "\n";
}

print $auth_res->decoded_content;

my $auth_data = $json_codec->decode($auth_res->decoded_content);

print Dumper $auth_data;

# Assuming the token is returned in the 'result' field of the JSON-RPC response
my $auth_token = $auth_data->{'result'}{'auth'};

print "Auth Token: $auth_token\n";

if (!$auth_token) {
    die "Failed to retrieve auth token. Response was:\n" . Dumper($auth_data);
}

print "Successfully authenticated. Token acquired.\n\n";
print "=== Step 2: Dispatching Event ===\n";

# Construct the Event payload matching your _dispatch method
# We wrap the event in an array reference as expected by parse_and_add

my $severity = shift;
$severity = 1 unless defined $severity;
my $events = {
        varbinds => [ { 'sequence_id' => '12345' } ],
        source   => '10.0.0.50',
        message  => 'Sample event from RPC client',
        severity => "$severity",
	event_id => 'test',
	dedup_id => 'test' 
    };

$events->{dedup_id} .= "|" . $events->{severity};

my $dispatch_id = "Dispatch $$ at " . time;

my $dispatch_payload = {
    method  => 'event.parse_and_add',
    params  => $events,
    jsonrpc => '2.0',
    id      => $dispatch_id,
    auth    => $auth_token, # Passing the token at the root level as requested
};

my $dispatch_req = POST(
    "$base_url/WebServices",
    Content_Type => 'application/json',
    Content      => $json_codec->encode($dispatch_payload)
);

my $dispatch_res = $ua->request($dispatch_req);

if ($dispatch_res->is_success) {
    print "Dispatch HTTP Request Successful!\n";
    my $dispatch_data = $json_codec->decode($dispatch_res->decoded_content);
    print Dumper($dispatch_data);
} else {
    print "Dispatch HTTP Request Failed: " . $dispatch_res->status_line . "\n";
    print "Response body: " . $dispatch_res->decoded_content . "\n";
}