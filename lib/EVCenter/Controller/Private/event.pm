package EVCenter::Controller::Private::event;
use Moose;
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

=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
