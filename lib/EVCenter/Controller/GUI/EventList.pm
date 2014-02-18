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

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->go('EventList');

}

=head2 EventList

=cut

sub EventList :Local :Args(0) {
	my ( $self, $c ) = @_;

    my ($rows, $fields) = $c->model('Event')->get_events(limit => 30);

    if (! $rows) {
	    die $c->model('Event')->errstr;
    }

    $c->stash(fields => $fields, rows => $rows);
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
