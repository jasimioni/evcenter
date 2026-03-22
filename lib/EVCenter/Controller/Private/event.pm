package EVCenter::Controller::Private::event;
use Moose;
use JSON::MaybeXS qw(decode_json encode_json);
use POSIX qw(strftime);
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

EVCenter::Controller::Private::event - Catalyst Controller

=head1 DESCRIPTION

Private methods to be used by the GUI and the WebServices Controllers.
The idea is pretty simple - all methods are private, and return the
information needed.

O retorno de todos os métodos é um hashref com 'result' e 'error'

=head1 METHODS

=cut


=head2 index

=cut

sub parse_and_add :Private {
	# Parse event information before calling add 
	# AKA Rules Engine
	my ( $self, $c, $params ) = @_;
	my $new_events;
	if (ref $params eq 'ARRAY') {
		$new_events = $params;
	} elsif (ref $params eq 'HASH') {
		$new_events = [ $params ];
	} else {
		return { error => { 
					code => 'INVALID_METHOD_PARAMETER', 
					message => 'Invalid method parameter(s). Must provide a hashref or an arrayref of hashrefs'
				} };
	}

	my @events_to_add;
	foreach my $event (@$new_events) {
		my ($seq) = values %{$event->{varbinds}[0]};
		push @events_to_add, $c->model('Processor')->process_event($event);
	}
	$c->forward('add', [ \@events_to_add ]);
}

sub add :Private {
	my ( $self, $c, $params ) = @_;

	my $new_events;

	if (ref $params eq 'ARRAY') {
		$new_events = $params;
	} elsif (ref $params eq 'HASH') {
		$new_events = [ $params ];
	} else {
		return { error => { 
					code => 'INVALID_METHOD_PARAMETER', 
					message => 'Invalid method parameter(s). Must provide a hashref or an arrayref of hashrefs'
				} };
	}

	my $rows = $c->model('Event')->add_events($new_events);	
	if (defined $rows) {
		return { result => "$rows new events added" };
	} else {
		return { error => {
					code => 'DATABASE_ACTION_FAILURE',
					message => 'Failed to add events: ' . $c->model('Event')->errstr,
				} };
	}
}

sub get :Private {
	my ( $self, $c, $params ) = @_;

	$params = {} if (! defined $params);

	if (ref $params ne 'HASH') {
		return { error => { 
				code => 'INVALID_METHOD_PARAMETER', 
				message => 'Invalid method parameter(s). Must provide a hashref'
				} };			
	}

	$params->{restrict} = $c->session->{srf};
	use Data::Dumper;
	$c->log->debug(Dumper $params);

	my ($rows, $columns) = $c->model('Event')->get_events(%$params);

	if (defined $rows) {
		return { result => { rows => $rows, columns => $columns } };
	} else {
		return { error => {
					code => 'DATABASE_ACTION_FAILURE',
					message => 'Failed to get events: ' . $c->model('Event')->errstr,
				} };
	}	
	
}

sub upd :Private {
	my ( $self, $c, $params ) = @_;

	$params = {} if (! defined $params);
	
	$c->log->debug("Received update request with params: " . encode_json($params));

	if (ref $params ne 'HASH') {
		return { error => {
				code => 'INVALID_METHOD_PARAMETER',
				message => 'Invalid method parameter(s). Must provide a hashref'
				} };
	}

	$params->{restrict} = $c->session->{srf};
	my $username = $c->user->id;
	my $groups = $c->session->{user_groups} || [];
	my $group_uid = @$groups ? $groups->[0] : undef;

	$c->log->debug("Applying update with filter: " . encode_json($params->{filter}) . " and restrict: " . encode_json($params->{restrict}));

	my ($rows, $columns) = $c->model('Event')->get_events(
		filter   => $params->{filter},
		restrict => $params->{restrict},
		columns  => [ 'serial', 'ack', 'suppression', 'severity', 'clear_time', 'start_severity', 'dedup_id', 'owner_uid' ],
	);

	$c->log->debug("Events retrieved for update: " . encode_json({ rows => $rows, columns => $columns }));

	if (! defined $rows) {
		return { error => {
					code => 'DATABASE_ACTION_FAILURE',
					message => 'Failed to load events for update: ' . $c->model('Event')->errstr,
				} };
	}

	my %column_index = map { $columns->[$_] => $_ } 0 .. $#$columns;
	my @base_history_actions;
	if (exists $params->{update}{ack}) {
		push @base_history_actions, $params->{update}{ack} ? 'acked' : 'unacked';
	}
	if (exists $params->{update}{suppression}) {
		push @base_history_actions, $params->{update}{suppression} ? 'suppressed' : 'unsuppressed';
	}
	if (exists $params->{update}{severity} && ! exists $params->{update}{restore_severity}) {
		push @base_history_actions, $params->{update}{severity} == 0 ? 'cleared' : 'uncleared';
	}
	if (exists $params->{update}{clear_time}) {
		push @base_history_actions, defined $params->{update}{clear_time} ? 'cleared' : 'uncleared';
	}

	my $updated_rows = 0;
	foreach my $row (@$rows) {
		my %update = (%{$params->{update}});
		my @history_actions = @base_history_actions;

		if (exists $update{restore_severity} && $update{restore_severity}) {
			$update{severity} = $row->[$column_index{start_severity}];
			delete $update{restore_severity};
			if (defined $update{severity}) {
				push @history_actions, $update{severity} == 0 ? 'cleared' : 'uncleared';
			}
		}

		my $log_message = join(', ', @history_actions);
		$update{owner_uid} = $username;
		$update{group_uid} = $group_uid;

		$c->log->debug("Updating event serial " . $row->[$column_index{serial}] . " with update: " . encode_json(\%update));

		my $rows = $c->model('Event')->upd_events(
			filter   => { serial => $row->[$column_index{serial}] },
			restrict => $params->{restrict},
			update   => \%update,
		);

		if (! defined $rows) {
			return { error => {
						code => 'DATABASE_ACTION_FAILURE',
						message => 'Failed to update events: ' . $c->model('Event')->errstr,
					} };
		}

		if ($log_message) {
			my $log_result = $c->model('Event')->add_log(
				event_serial   => $row->[$column_index{serial}],
				evend_dedup_id => $row->[$column_index{dedup_id}],
				owner_uid      => $row->[$column_index{owner_uid}],
				log_message    => $log_message,
			);
			if (! defined $log_result) {
				return { error => {
							code => 'DATABASE_ACTION_FAILURE',
							message => 'Failed to add log entry: ' . $c->model('Event')->errstr,
						} };
			}
		}

		$updated_rows += $rows;
	}

	if (defined $updated_rows) {
		return { result => { rows => $updated_rows } };
	} else {
		return { error => {
					code => 'DATABASE_ACTION_FAILURE',
					message => 'Failed to update events: ' . $c->model('Event')->errstr,
				} };
	}
}

sub get_columns :Private {
	my ( $self, $c ) = @_;

	my $columns = $c->model('Event')->columns;
	if (defined $columns) {
		return { result => { columns => $columns } };
	} else {
		return { error => {
					code => 'DATABASE_ACTION_FAILURE',
					message => 'Failed to get columns',
				} };
	}
}

sub get_log :Private {
	my ( $self, $c, $params ) = @_;

	$params = {} if (! defined $params);

	if (ref $params ne 'HASH') {
		return { error => {
				code => 'INVALID_METHOD_PARAMETER',
				message => 'Invalid method parameter(s). Must provide a hashref'
				} };
	}

	my ($rows, $columns) = $c->model('Event')->get_logs(
		filter => $params->{filter} || {},
	);

	if (defined $rows) {
		return { result => { rows => $rows, columns => $columns } };
	} else {
		return { error => {
					code => 'DATABASE_ACTION_FAILURE',
					message => 'Failed to get logs: ' . $c->model('Event')->errstr,
				} };
	}
}

=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
