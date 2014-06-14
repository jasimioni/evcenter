package EVCenter::Controller::GUI;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

EVCenter::Controller::GUI - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub PopulateViewData :Private {
    # TODO: Throw error if no return
    my ( $self, $c ) = @_;

    my $views = $c->forward('/Private/usercontrol/get_user_views', 
                           [ { user => $c->user->id } ]);

    my %ui_views = (
        id     => {},
        user   => [],
        global => [],
        group  => [],
        select => {
            user   => [],
            group  => [],
            global => [],
        },
    );

    foreach my $view (@{$views->{result}}) {
        $ui_views{id}{$view->{view_id}} = $view;
        push @{$ui_views{$view->{owner_type}}}, $view;
    }

    $ui_views{id}{0} = {
        view_name => 'All Fields',
        view      => undef,
    };

    $ui_views{select}{user}   = [ sort { $a->{view_name} <=> $b->{view_name} } @{$ui_views{user}} ];
    $ui_views{select}{group}  = [ sort { $a->{owner}       <=> $b->{owner} || 
                                         $a->{view_name} <=> $b->{view_name} } @{$ui_views{group}} ];
    $ui_views{select}{global} = [ sort { $a->{view_name} <=> $b->{view_name} } @{$ui_views{global}} ];

    $c->session(ui_views => \%ui_views); 
}

sub PopulateFilterData :Private {
    # TODO: Throw error if no return
    my ( $self, $c ) = @_;

    my $filters = $c->forward('/Private/usercontrol/get_user_filters', 
                             [ { user => $c->user->id } ]);

    my %ui_filters = (
        id     => {},
        user   => [],
        global => [],
        group  => [],
        select => {
            user   => [],
            group  => [],
            global => [],
        },
    );

    foreach my $filter (@{$filters->{result}}) {
        $ui_filters{id}{$filter->{filter_id}} = $filter;
        push @{$ui_filters{$filter->{owner_type}}}, $filter;
    }

    $ui_filters{id}{0} = {
        filter_name => 'No Filter',
        filter      => undef,
    };

    $ui_filters{select}{user}   = [ sort { $a->{filter_name} <=> $b->{filter_name} } @{$ui_filters{user}} ];
    $ui_filters{select}{group}  = [ sort { $a->{owner}       <=> $b->{owner} || 
                                         $a->{filter_name} <=> $b->{filter_name} } @{$ui_filters{group}} ];
    $ui_filters{select}{global} = [ sort { $a->{filter_name} <=> $b->{filter_name} } @{$ui_filters{global}} ];

    $c->session(ui_filters => \%ui_filters);
}

sub GetViewOptions :Local {
    my ( $self, $c ) = @_;

    # Repopulate filter data
    $c->forward('/GUI/PopulateViewData');

    $c->stash(current_view => 'JSON');
    $c->stash(jsonrpc_output => $c->session->{ui_views}{select});
}

sub GetFilterOptions :Local {
    my ( $self, $c ) = @_;

    # Repopulate filter data
    $c->forward('/GUI/PopulateFilterData');

    $c->stash(current_view => 'JSON');
    $c->stash(jsonrpc_output => $c->session->{ui_filters}{select});
}

sub auto :Private {
    my ($self, $c) = @_;

    $c->stash('menu' => [
        {
            icon   => 'fa-home',
            name   => 'Home',
            link   => $c->uri_for('/'),
            active => 0,
            id     => 'home',
        },
        {
            icon   => 'fa-list',
            name   => 'Event List',
            link   => $c->uri_for('/GUI/EventList'),
            active => 0, 
            id     => 'eventlist',
        },
        {
            icon   => 'fa-wrench',
            name   => 'Administration',
            link   => $c->uri_for('/GUI/Admin'),
            active => 0, 
            id     => 'admin',
            submenu => [
                {
                    name => 'Users and Groups',
                    link => $c->uri_for('/GUI/Admin/Users')
                },
                {
                    name => 'Roles',
                    link => $c->uri_for('/GUI/Admin/Roles')
                },
                {
                    name => 'Filters',
                    link => $c->uri_for('/GUI/Admin/Filters')
                },
                {
                    name => 'Views',
                    link => $c->uri_for('/GUI/Admin/Views')
                },
            ],
        }
    ]);

    $c->stash(pagehead => { title => 'Home', icon => 'icon-home' });

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
