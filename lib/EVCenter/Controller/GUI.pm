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
            # submenu => \@appsMenu,
        },
        {
            icon   => 'fa-wrench',
            name   => 'Administration',
            link   => $c->uri_for('/GUI/Admin'),
            active => 0, 
            id     => 'admin',
        }
    ]);

    $c->stash(pagehead => { title => 'Home', icon => 'icon-home' });

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
