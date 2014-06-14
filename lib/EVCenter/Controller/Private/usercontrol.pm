package EVCenter::Controller::Private::usercontrol;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched EVCenter::Controller::Private::usercontrol in Private::usercontrol.');
}

sub set_user_details :Private {
    my ( $self, $c, $params ) = @_;

    my $user    = $params->{user};
    my $details = $params->{details};

    if ($c->model('UserControl')->set_user_details($user, $details)) {
        return { result => 'Details set for user' };
    } else {
        return { error => {
                    code => 'USER_UPDATE_FAILURE',
                    message => "Failed to update user details: " . $c->model('UserControl')->errstr,
                } };
    }
}

sub get_user_filters :Private {
    my ( $self, $c, $params ) = @_;

    my $user = $params->{user};

    if (my $filters = $c->model('ACL')->get_ui_filters($user)) {
        return { result => $filters };
    } else {
        return { error => {
                    code => 'GET_USER_DATA_FAILURE',
                    message => "Failed to get filters from user: " . $c->model('ACL')->errstr,
                } };

    }
}

sub get_user_views :Private {
    my ( $self, $c, $params ) = @_;

    my $user = $params->{user};

    if (my $views = $c->model('ACL')->get_ui_views($user)) {
        return { result => $views };
    } else {
        return { error => {
                    code => 'GET_USER_DATA_FAILURE',
                    message => "Failed to get views from user: " . $c->model('ACL')->errstr,
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
