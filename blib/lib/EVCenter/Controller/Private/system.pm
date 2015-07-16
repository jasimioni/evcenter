package EVCenter::Controller::Private::system;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

EVCenter::Controller::Private::system - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub check_server :Private {
	my ( $self, $c ) = @_;

	my $dbstatus = $c->model('Event')->check_db;
	if (defined $dbstatus) {
		return { result => "Server is Up and Running" };
	} else {
		return { error => {
					code => 'DATABASE_NOT_OPERATIONAL',
					message => 'Database is not operational',
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
