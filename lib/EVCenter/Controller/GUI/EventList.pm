package EVCenter::Controller::GUI::EventList;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

EVCenter::Controller::GUI::EventList - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub RetrieveEvents :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $json = {};
    $c->stash(current_view => 'JSON');

    # TODO - Get Field List from View (from parameters)
    my $return = $c->forward('/Private/event/get', [ { columns => [ 'serial', 'severity', 'ack', '*' ],
                                                       limit   => $c->req->param('limit') 
                                                     } ]);  
    my $result = $return->{result};

    if (! defined $result) {
        die $return->{error}{message};
    }

    my $rows = $result->{rows};

    $json = {
        page     => 1,
        total    => 1,
        records  => scalar @$rows,
        rows     => [],
        ctrlrows => [],
    };
    $c->stash('jsonrpc_output' => $json);

    my ($serial, $severity, $ack);
    my @sevcount = (0, 0, 0, 0, 0, 0);
    foreach my $row (@$rows) {
        ($serial, $severity, $ack) = splice(@$row, 0, 3);
        $sevcount[$severity]++;
        push @{$json->{ctrlrows}}, { serial => $serial, severity => $severity, ack => $ack };
        push @{$json->{rows}}, {
            id   => $serial,
            cell => $row,
        };
    }
    $json->{sevcount} = {
        clear        => $sevcount[0],
        undetermined => $sevcount[1],
        warning      => $sevcount[2],
        minor        => $sevcount[3],
        major        => $sevcount[4],
        critical     => $sevcount[5],
    }
}

sub EventList :Path :Args(0) {
	my ( $self, $c ) = @_;

    my $fullscreen = $c->req->param('fullscreen');
    if ($fullscreen eq 'yes') {
        $c->stash(current_view => 'HTMLBasic');
    }

    # Get Field List from View
    my $return = $c->forward('/Private/event/get_columns');
    my $result = $return->{result};

    if (! defined $result) {
	    die $return->{error}{message};
    }

    my $columns = $result->{columns};

    $c->stash(columns => $columns);
}

sub auto :Private {
    my ($self, $c) = @_;

    foreach my $item (@{$c->stash->{menu}}) {
        $item->{active} = 1 if $item->{id} eq 'eventlist';
    }

    $c->stash(pagehead => { title => 'Event List', icon => 'fa-list' });

    return 1;
}

=encoding utf8

=head1 AUTHOR

João André Simioni

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
