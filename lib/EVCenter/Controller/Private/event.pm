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

sub add {
	my ( $self, $c, $params ) = @_;

	use Data::Dumper;
	$c->log->debug(Dumper $params);

	return { result => 'Events Added' };
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
