package EVCenter::Controller::GUI::Admin;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

EVCenter::Controller::GUI::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
}

sub Users :Local :Args(0) {
    my ( $self, $c ) = @_;


}

sub auto :Private {
    my ($self, $c) = @_;

    foreach my $item (@{$c->stash->{menu}}) {
        $item->{active} = 1 if $item->{id} eq 'admin';
    }

    $c->stash(pagehead => { title => 'Administration', icon => 'fa-wrench' });

    return 1;
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
