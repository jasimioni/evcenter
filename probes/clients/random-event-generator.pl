#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep time);
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use JSON;

my $base_url = $ENV{EVCENTER_URL}      // 'http://127.0.0.1:3000';
my $username = $ENV{EVCENTER_USERNAME} // 'probe';
my $password = $ENV{EVCENTER_PASSWORD} // 'snmp';

my $ua = LWP::UserAgent->new(timeout => 10);
my $json_codec = JSON->new->utf8;

my @nodes = (
	'server-app-01',
	'server-app-02',
	'server-app-03',
	'server-app-04',
	'server-db-01',
	'server-db-02',
	'server-web-01',
	'server-web-02',
	'router-edge-01',
	'router-edge-02',
	'router-core-01',
	'router-core-02',
	'router-wan-01',
	'router-wan-02',
	'switch-access-01',
	'switch-access-02',
	'switch-access-03',
	'switch-dist-01',
	'switch-dist-02',
	'switch-core-01',
);

my @objects = (
	'interface:eth0',
	'interface:eth1',
	'interface:eth2',
	'interface:eth3',
	'interface:bond0',
	'cpu:total',
	'cpu:core0',
	'cpu:core1',
	'memory:ram',
	'memory:swap',
	'filesystem:/',
	'filesystem:/var',
	'filesystem:/tmp',
	'filesystem:/home',
	'power:psu1',
	'power:psu2',
	'temperature:chassis',
	'fan:tray1',
	'bgp:neighbor-1',
	'ospf:adjacency-1',
);

my %messages_by_family = (
	interface => {
		fault => [
			'Interface errors increased above threshold',
			'Interface is flapping',
			'Interface input drops are high',
		],
		resolution => [
			'Interface errors returned to normal',
			'Interface flap condition cleared',
			'Interface input drops normalized',
		],
	},
	cpu => {
		fault => [
			'CPU usage exceeded threshold',
			'CPU sustained high utilization',
			'CPU load average is critical',
		],
		resolution => [
			'CPU usage returned to normal',
			'CPU utilization stabilized',
			'CPU load average recovered',
		],
	},
	memory => {
		fault => [
			'Memory usage exceeded threshold',
			'Swap utilization is high',
			'Memory pressure detected',
		],
		resolution => [
			'Memory usage returned to normal',
			'Swap utilization normalized',
			'Memory pressure cleared',
		],
	},
	filesystem => {
		fault => [
			'Filesystem usage exceeded threshold',
			'Filesystem is almost full',
			'Filesystem write latency is high',
		],
		resolution => [
			'Filesystem usage returned to normal',
			'Filesystem free space recovered',
			'Filesystem write latency normalized',
		],
	},
	power => {
		fault => [
			'Power supply anomaly detected',
			'Power supply output unstable',
		],
		resolution => [
			'Power supply status recovered',
			'Power supply output stabilized',
		],
	},
	temperature => {
		fault => [
			'Chassis temperature exceeded threshold',
			'Thermal alarm is active',
		],
		resolution => [
			'Chassis temperature returned to normal',
			'Thermal alarm cleared',
		],
	},
	fan => {
		fault => [
			'Fan speed below expected value',
			'Fan fault detected',
		],
		resolution => [
			'Fan speed returned to normal',
			'Fan fault cleared',
		],
	},
	bgp => {
		fault => [
			'BGP neighbor session down',
			'BGP prefix count below baseline',
		],
		resolution => [
			'BGP neighbor session restored',
			'BGP prefix count back to baseline',
		],
	},
	ospf => {
		fault => [
			'OSPF adjacency lost',
			'OSPF neighbor state degraded',
		],
		resolution => [
			'OSPF adjacency restored',
			'OSPF neighbor state normalized',
		],
	},
);

sub authenticate {
	my $auth_payload = {
		method  => 'auth',
		params  => { username => $username, password => $password },
		jsonrpc => '2.0',
		id      => "auth-$$-" . time,
	};

	my $auth_req = POST(
		"$base_url/WebServices",
		Content_Type => 'application/json',
		Content      => $json_codec->encode($auth_payload),
	);

	my $auth_res = $ua->request($auth_req);
	die 'Authentication HTTP Request Failed: ' . $auth_res->status_line . "\n"
		if !$auth_res->is_success;

	my $auth_data = $json_codec->decode($auth_res->decoded_content);
	my $auth_token = $auth_data->{result}{auth};
	die "Failed to retrieve auth token\n" if !$auth_token;

	return $auth_token;
}

sub random_from {
	my ($array_ref) = @_;
	return $array_ref->[int(rand(@$array_ref))];
}

sub build_event {
	my ($seq) = @_;

	my $node = random_from(\@nodes);
	my $object = random_from(\@objects);
	my ($family) = split(/:/, $object, 2);

	my $is_resolution = rand() < 0.30 ? 1 : 0;
	my $type = $is_resolution ? 2 : 1;
	my $severity = $is_resolution ? 1 : 2 + int(rand(4));

	my $message_pool = $is_resolution
		? $messages_by_family{$family}{resolution}
		: $messages_by_family{$family}{fault};
	my $message = random_from($message_pool);

	my $event_id = join('|', $node, $object);
	my $dedup_id = join('|', $node, $object, $severity);

	return {
		varbinds   => [ { sequence_id => $seq } ],
		source     => $node,
		probe_type => 'Default',
		node       => $node,
		object     => $object,
		message    => $message,
		type       => $type,
		severity   => $severity,
		event_id   => $event_id,
		dedup_id   => $dedup_id,
	};
}

sub dispatch_event {
	my ($auth_token, $event) = @_;

	my $dispatch_payload = {
		method  => 'event.parse_and_add',
		params  => $event,
		jsonrpc => '2.0',
		id      => "dispatch-$$-" . time,
		auth    => $auth_token,
	};

	my $dispatch_req = POST(
		"$base_url/WebServices",
		Content_Type => 'application/json',
		Content      => $json_codec->encode($dispatch_payload),
	);

	return $ua->request($dispatch_req);
}

sub random_interval_seconds {
	# Exponential interval with mean 5s for bursty, random arrivals.
	my $u = rand();
	$u = 1e-9 if $u <= 0;
	my $seconds = -5 * log(1 - $u);

	# Keep intervals within an operationally practical range.
	$seconds = 0.2 if $seconds < 0.2;
	$seconds = 30  if $seconds > 30;
	return $seconds;
}

my $auth_token = authenticate();
print "Authenticated successfully. Starting random event generation...\n";

my $sequence = time;
while (1) {
	$sequence++;
	my $event = build_event($sequence);

	my $response = dispatch_event($auth_token, $event);

	if ($response->is_success) {
		print scalar(localtime())
			. ' sent event'
			. ' type=' . $event->{type}
			. ' severity=' . $event->{severity}
			. ' node=' . $event->{node}
			. ' object=' . $event->{object}
			. "\n";
	} else {
		print scalar(localtime()) . ' dispatch failed: ' . $response->status_line . "\n";

		# Re-auth in case token expired.
		eval { $auth_token = authenticate(); 1 };
		if ($@) {
			print scalar(localtime()) . " re-authentication failed\n";
		} else {
			print scalar(localtime()) . " re-authentication succeeded\n";
		}
	}

	sleep(random_interval_seconds());
}
