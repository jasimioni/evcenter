package EVCenter::Controller::Auth;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

EVCenter::Controller::GUI::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->redirect($c->uri_for('login'));
}

sub login :Local :Args(0) {
    my  ( $self, $c ) = @_;

    $c->stash(current_view => 'HTMLBasic');

    my $username = $c->req->param('username');
    my $password = $c->req->param('password');
    my $action   = $c->req->param('action');

    if ($action eq 'login') {
        $c->logout if ($c->user_exists);

        if ($c->authenticate({ username => $username, password => $password })) {
            $c->forward('calculate_permissions');
            $c->response->redirect($c->uri_for('/GUI/EventList'));
        } else {
            push @{$c->stash->{warns}}, [ 'error', 'Unable to login - username or password invalid' ];
        }
    }
}

sub logout :Local :Args(0) {
    my  ( $self, $c ) = @_;

    $c->logout;
    $c->delete_session;
    $c->response->redirect($c->uri_for('/Auth/login'));
}

sub calculate_permissions :Private {
    my ( $self, $c ) = @_;

    $c->session('srf'          => $c->model('ACL')->get_filter($c->user->id));        # SQL Restriction Filter
    $c->session('acl'          => $c->model('ACL')->get_permissions($c->user->id));   # Access Control List
    $c->session('user_groups'  => $c->model('ACL')->get_all_user_groups($c->user->id));
    $c->session('user_details' => $c->model('UserControl')->get_user_details($c->user->id));

    use Data::Dumper;
    $c->log->debug("SQL Restriction Filter: " . Dumper $c->session->{srf});
    $c->log->debug("Details: " . Dumper $c->session->{user_details});
    $c->log->debug("Groups: " . Dumper $c->session->{user_groups});
    $c->log->debug("UI Filters: " . Dumper $c->session->{ui_filters});
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
