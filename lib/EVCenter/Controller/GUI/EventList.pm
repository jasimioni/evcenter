package EVCenter::Controller::GUI::EventList;
use Moose;
use namespace::autoclean;
use JSON::MaybeXS;
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

sub SaveOptions :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(current_view => 'JSON');

    my $return = $c->forward('/Private/usercontrol/set_user_details', 
                             [ { user => $c->user->id, 
                                 details => { postData => $c->req->parameters },
                               } 
                             ]);

    $c->session('user_details' => $c->model('UserControl')->get_user_details($c->user->id));
    $c->stash('jsonrpc_output' => $return);
}

sub RetrieveEvents :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $json = {};
    $c->stash(current_view => 'JSON');

    my $ackfilter  = $c->req->param('ackfilter');
    my $suppfilter = $c->req->param('suppfilter');
    my $filterid   = $c->req->param('filterid');
    my $viewid     = $c->req->param('viewid');

    my @filters;
    my $filter = $c->session->{ui_filters}{id}{$filterid}{filter};
    push @filters, decode_json($filter) if (defined $filter);

    my $view;
    $view = $c->session->{ui_views}{id}{$viewid}{view};

    if ($ackfilter eq 'acked') {
        push @filters, [ ack => 1 ];
    } elsif ($ackfilter eq 'unacked') {
        push @filters, [ ack => 0 ];
    }

    if ($suppfilter eq 'suppressed') {
        push @filters, [ suppression => { '!=' => 0 } ];
    } elsif ($suppfilter eq 'notsuppressed') {
        push @filters, [ suppression => 0 ];
    }

    # In the future, I should change this forward to a CallWebServiceInternally Plugin
    my $return = $c->forward('/Private/event/get', [ { columns => [ 'serial', 'severity', 'ack', '*' ],
                                                       limit   => $c->req->param('limit'),
                                                       filter  => { -and => \@filters },
                                                     } ]);  
    my $result = $return->{result};

    if (! defined $result) {
        $json = {
            error => 'Failed to retrieve events: ' . $return->{error}{message}
        };
        $c->stash('jsonrpc_output' => $json);
        $c->response->status(400);
        return 1;
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

    # $c->session->{user_details}{postData} is populated on login
    my $ackfilter  = $c->req->param('ackfilter')  // $c->session->{user_details}{postData}{ackfilter};
    my $suppfilter = $c->req->param('suppfilter') // $c->session->{user_details}{postData}{suppfilter};
    my $filterid   = $c->req->param('filterid')   // $c->session->{user_details}{postData}{filterid} || 0;
    my $viewid     = $c->req->param('viewid')     // $c->session->{user_details}{postData}{viewid} || 0;

    # Populates the list of filters and Views the user has available to him
    # This is intended to update the filter and view list on the first load 
    # of the EventList
    $c->forward('/GUI/PopulateFilterData');
    $c->forward('/GUI/PopulateViewData');

    $c->stash->{gui} = {
        ackfilter  => $ackfilter,
        suppfilter => $suppfilter,
        filterid   => $filterid,
        viewid     => $viewid,
        filtername => $c->session->{ui_filters}{id}{$filterid}{filter_name} // 'Filter ID Not Defined',
        viewname   => $c->session->{ui_views}{id}{$viewid}{view_name}       // 'View ID Not Defined',
    };

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
