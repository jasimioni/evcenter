package EVCenter::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

EVCenter::Controller::Root - Root Controller for EVCenter

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->redirect($c->uri_for('/GUI/EventList'));
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head2 auto

Runs on every execution of any method

=cut

sub auto :Private {
    my ($self, $c) = @_;

    return 1 if ($c->req->path =~ /^WebServices/ ||
                 $c->user_exists                 ||
                 $c->req->path =~ /^Auth/);

    $c->response->redirect($c->uri_for('/Auth/login'));
    return 0;
}

=head1 AUTHOR

João André Simioni

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
