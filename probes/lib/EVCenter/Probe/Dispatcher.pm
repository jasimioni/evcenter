package EVCenter::Probe::Dispatcher;

use common::sense;
use Moose;
use Carp qw/croak/;
use Log::Log4perl qw/get_logger/;
use AnyEvent; BEGIN { AnyEvent::common_sense }
use Data::Dumper;
use AnyEvent::HTTP;
use JSON::MaybeXS;
use Try::Tiny;
use EVCenter::Probe::Storer;

has log            => (is => 'ro', isa => 'Object', default => sub { get_logger });
has url            => (is => 'ro', isa => 'Str', required => 1);
has username       => (is => 'ro', isa => 'Str');
has password       => (is => 'ro', isa => 'Str'); 
has timeout    	   => (is => 'ro', isa => 'Int', default => 15);
has processing     => (is => 'rw', isa => 'HashRef', default => sub { {} });
has failed         => (is => 'rw', isa => 'HashRef', default => sub { {} });
has directory      => (is => 'rw', isa => 'Str', required => 1);
has probe_id       => (is => 'rw', isa => 'Str');
has storer     	   => (is => 'ro', isa => 'EVCenter::Probe::Storer', lazy_build => 1, builder => '_build_storer' );
has is_auth	   	   => (is => 'rw', isa => 'Int', default => 0);
has authenticating => (is => 'rw', isa => 'Int', default => 0);
has authid     	   => (is => 'rw', isa => 'Str');
has server_ok      => (is => 'rw', isa => 'Int', default => 1);
has queue		   => (is => 'rw', isa => 'HashRef', default => sub { {} });
has max_tries	   => (is => 'ro', isa => 'Int', default => 3);
has timer		   => (is => 'rw');
has jobs           => (is => 'rw', isa => 'Int', default => 0);
has max_jobs       => (is => 'ro', isa => 'Int', default => 50);
has queue_expire   => (is => 'ro', isa => 'Int', default => 10800);

=encoding utf8

=head1 NAME

EVCenter::Probe::Dispatcher - Class to dispatch events to EVCenter Core

=head1 SYNOPSIS

    use EVCenter::Probe::Dispatcher;

    $dispatcher = EVCenter::Probe::Dispatcher->new(   url          => $url,  
                                                      directory    => $directory,
                                                    [ username     => $username  ],
                                                    [ password     => $password  ],
                                                    [ is_auth      => $is_auth   ]
                                                    [ timeout      => $timeout   ],
                                                    [ probe_id     => $probe_id  ],
                                                    [ max_jobs     => $max_jobs  ],
                                                    [ max_tries    => $max_tries ],
                                                    [ queue_expire => $queue_expire ]
                                                    );

    $dispatcher->enqueue(events => [ @events ], [ id => $id ]);



=head1 DESCRIPTION

This class is used to dispatch events to EVCenter Core. It must be provided
an URL for the WebService and a Directory where it will store the files being
processed.

All http requests are non-blocking, using L<AnyEvent::HTTP>. For that to work as
expected, the main program must be in an AnyEvent loop. That can be achieved by doing:

    use AnyEvent;
    $cv = AnyEvent->condvar;
    $cv->recv;

=head1 ATTRIBUTES

=head2 url

Contains the URL where the EVCenter Core is accepting connections. Communication
is done using L<JSON-RPC|http://json-rpc.org/>.

=head2 directory

Place where files representing each transaction will be store. Usually these files
will be incremented with traps, using the storer method store. On success, files
will be renamed to .done and on failure to .failed.

=head2 username, password and is_auth

Username and Password to authenticate against the WebService. If none is supplied,
is_auth should be set to 1, so it will not try to authenticate before processing
any events.

=head2 timeout

Time, in seconds, before the http request leaves due to time out.

=head2 probe_id

An identifier of the probe being run. It will precede all files used by the storer.

=head2 max_jobs

Number of concurrent jobs (http requests) allowed.

=head2 max_tries

On failure to process, how many times should the event packet be resent to
EVCenter Core before giving up.

=head2 queue_expire

If request is on queue for more then this paremeter, in seconds, set to fail 
and remove from queue.

=head1 LOGGING

There is an attibute I<log>, which is a Log::Log4perl object, obtained by the
C<get_logger> call. It's used for logging purposes.

=head1 WORKFLOW SUMMARY

The basic workflow used by this module is:

enqueue objects -> call _process_queue -> is there any expired request on queue ?

yes -> set to fail and remove from queue

no -> is server up ? 

no -> keep checking server untill it's up, using _check_server.

yes -> is_auth ?

no -> keep trying to authenticate until it's authenticated.

yes -> send request to EVCenter Core to process the events. Removes from queue and make sure max_jobs
is respected.

On request finish, was request successful ?

yes -> we are good, mark stored file as .done and no more action

no -> What kind of failure?

auth? -> requeue and starts authentication process. Will reprocess on successful auth

server failure? -> requeue and starts check server process. Will reprocessed when server is up.

other? requeue. Will reprocess immediatly.

Will reprocess at maximum max_tries (counting first one).

max_tries reached ? mark stored file as .failed and no more action.

=head1 METHODS

=cut

# Create the storer object, which is responsible for storing events
# for reprocessing in case of failure of main server.
sub _build_storer {
	my $self = shift;
	my %params = (directory => $self->directory);
	$params{probe_id} = $self->probe_id if (defined $self->probe_id);

	my $storer = EVCenter::Probe::Storer->new(%params);
	$self->probe_id($storer->probe_id);
	$self->directory($storer->directory);

	return $storer;
}

# BUILD will run just after the object is created, but before returning.
# Only here to be sure that the storer object is created, since it's 
# lazy built by Moose.
sub BUILD {
	my $self = shift;
	$self->storer->probe_id; # Just Making Sure storer will be created
}

# ->_http_post
# This will take a json argument, send to the webservice, and will
# call $callback when the http request returns or time out.
sub _http_post {
	my ( $self, $json, $callback ) = @_;

	my $body = encode_json $json;

	$self->log->debug("Sending body: $body");
	http_post $self->url, $body, headers => { 'Content-Type' => 'application/json' }, timeout => $self->timeout, $callback;
}

# ->_process_return
# This is the callback the will be called when trying to add new events.
# It will handle authentication and server errors, by calling
# back the authentication or check_server processes
sub _process_return {
	my ( $self, $p, $data, $headers) = @_;

	my $id = $p->{id};
	$self->{jobs}--;
	try {
		if ($headers->{Status} != 200) {
			$self->server_ok(0);
			$self->_check_server;
			die "Failed to dispatch - received bad status from server - " . $headers->{Status};
		}

		my $response = decode_json $data;

		$self->log->debug(Dumper $response);

		if ($response->{error}) {
			if ($response->{error}{code} eq '20001') {
			# Error code 20001 => Previously processed the same request id
			# So should process as a successfull one - just warn
				$self->log->warn("Server stated as already processed. Acting as if it was successfull Server Message: ", $response->{error}{message});
			} else {
				if ($response->{error}{code} eq '10100') {
					# Authentication Required
					$self->_authenticate;
				} elsif ($response->{error}{code} >= 20000 && $response->{error}{code} < 21000) {
					# Explicit server information telling us something is wrong and we should wait for it to fix
					$self->_check_server;
				}
				die $response->{error}{message};
			}
		}

		$self->log->info("Successfully inserted events ", $response->{result});
		$self->storer->set_to_done($id);	
		delete $self->processing->{$id};
	} catch {
		$self->log->info("Error Message: $_");
		if ($self->processing->{$id}{tries}++ < $self->max_tries) {
			# Requeue
			$self->queue->{$id} = $self->processing->{$id};
			$self->log->info("Failed to process events for request id $id, but I'll try again, since this was try: ", $self->processing->{$id}{tries});
		} else {
			$self->log->error("Failed to process events for request id $id - setting store file to failed. I'm not trying again");
			$self->storer->set_to_failed($id);
			delete $self->processing->{$id};
		}
	};
	$self->_process_queue;
}

# ->_handle_authentication
# This is the callback to process the requests for authentication
sub _handle_authentication {
	my ( $self, $data, $headers) = @_;
	try {
		if ($headers->{Status} != 200) {
			die "Failed to authenticate - received bad status from server - " . $headers->{Status};
			$self->_check_server;
		}

		my $response = decode_json $data;

		$self->log->debug(Dumper $response);

		die $response->{error}{message} if ($response->{error});
		die "No authentication information returned" if ! defined $response->{result}{auth};

		$self->log->info("Successfully authenticated - authid: ", $response->{result}{auth});
		$self->authid($response->{result}{auth});
		$self->is_auth(1);
		$self->authenticating(0);
		$self->_process_queue;
	} catch {
		$self->log->info("Error Message: $_ - Trying Again in 5 seconds");
		$self->{timer} = AnyEvent->timer(after => 5, cb => sub { $self->_authenticate });
	};	
}

# ->_authenticate
# This method is called to start the authentication process.
sub _authenticate {
	my $self = shift;

	$self->authenticating(1);
	$self->is_auth(0);
	my $json = {
		method  => 'auth',
		params  => { username => $self->username, password => $self->password },
		jsonrpc => '2.0',
		id 		=> "Process $$ Authentication at " . time,
	};

	$self->log->info("Requesting Web Services Authentication with ", $self->username, " and ", $self->password);
	$self->_http_post($json, sub { $self->_handle_authentication(@_) });
}

# ->_handle_check_server
# This is the callback to process the request to check server availability
sub _handle_check_server {
	my ( $self, $data, $headers) = @_;
	try {
		if ($headers->{Status} != 200) {
			die "Failed to check server - received bad status from server - " . $headers->{Status};
		}

		my $response = decode_json $data;

		$self->log->debug(Dumper $response);

		# IF Error Code = 10101, server replied, but authentication is needed to get status
		if ($response->{error}) {
			if ($response->{error}{code} == 10100) {
				# Authentication required to check status. Setting the server up but marking
				# as unauthenticated
				$self->is_auth(0);
			} else {
				die $response->{error}{message} . ' - ' . $response->{error}{code};			
			}
		}

		$self->log->info("Server is up again - going on with our tasks");
		$self->server_ok(1);
		$self->_process_queue;
	} catch {
		$self->log->info("Error Message: $_ - Trying Again in 5 seconds");
		$self->{timer} = AnyEvent->timer(after => 5, cb => sub { $self->_check_server });
	};	
}

# ->_check_server
# Starts the checking for server availability
sub _check_server {
	my $self = shift;

	$self->server_ok(0);
	my $json = {
		method  => 'system.check_server',
		jsonrpc => '2.0',
		id      => "Process $$ checking server at " . time,
		auth    => $self->authid,
	};

	$self->log->info('Verifying server availability');
	$self->_http_post($json, sub { $self->_handle_check_server(@_) });
}

# ->_dispatch
# This method is called by the process queue for each group of events
# to be inserted.
sub _dispatch {
	my ( $self, %p ) = @_;

	my ($id, $events) = @p{'id', 'events'};

	my $json = {
		method  => 'event.parse_and_add',
		params  => $events,
		jsonrpc => '2.0',
		id 		=> $id,
		auth    => $self->authid,
	};

	$self->{jobs}++;

	$self->log->info("Dispatching id => ", $id);
	$self->log->debug('Increment jobs - now it is: ', $self->jobs);

	$self->_http_post($json, sub { $self->_process_return({ id => $id }, @_) });
		 									   
	$self->log->debug("Launched http_post for $id: ", sub { Dumper $self->processing->{$id} });
}

# ->_process_queue
# Invoked after each enqueue call and after the return of the callbacks
# to make sure the queue is consumed. It will delete expired requests
# before processing and make sure server is up and authentication was done
sub _process_queue {
	my $self = shift;

    my $now = time;
    # First let's check if we have expired requests
    # If queue is not empty
    foreach my $id (sort keys %{$self->queue}) {
        if ($now - $self->queue->{$id}{timestamp} > $self->queue_expire) {
            # Delete if timestamp is too old and set to fail
            $self->log->info("Removing $id from queue, because it is too old: ", 
                              scalar localtime($self->queue->{$id}{timestamp}));
            delete $self->{queue}{$id};
            $self->storer->set_to_failed($id);
        }
    }

	return if (! $self->server_ok);

	if ($self->is_auth) {
		while (%{$self->queue} && ( $self->jobs < $self->max_jobs || ! $self->max_jobs )) {
			if (my $id = (sort keys %{$self->queue})[0]) {
				my $events = $self->{queue}{$id}{events};
				delete $self->{queue}{$id};
				$self->_dispatch(id 		=> $id,
								 events 	=> $events);
			}
		}
	} elsif (! $self->authenticating) {
		$self->_authenticate;
	}
}

=head2 enqueue

This sould be the only method to be called from outside. It will take the 

    $dispatcher->enqueue(events => [ @events ], [ id => $id ]);

It will accept two named arguments (hash) - an array_ref with the events
to be inserted. Each event is an hash_ref contained any number of values,
that will be parsed by the EVCenter Core Rules.

Optionally an ID should be passed, or it will default to the current
id indicated by the storer.

It will place the events on the queue to be processed and immediatly invoke
the _process_queue method. _process_queue will check if server is up, 
authentication was done and launch http requests from the queue, guaranteeing
that the number of requests are below max_jobs attribute.

=cut
sub enqueue {
	my $self = shift;
	my %p = @_;

	my $id         = $p{id}			// $self->storer->current_id;
	my $events     = $p{events};

	$self->queue->{$id} 	 = { timestamp => time, events => $events, tries => 0 };
	$self->processing->{$id} = $self->queue->{$id};

	$self->_process_queue;
}

=head1 SEE ALSO

L<AnyEvent>, L<AnyEvent::HTTP>, L<EVCenter::Probe::Storer>, L<Log::Log4perl>

=head1 AUTHOR

Joao Andre Simioni <jasimioni@gmail.com>

=head1 LICENSE

TBD

=cut

1;
