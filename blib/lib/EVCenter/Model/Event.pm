package EVCenter::Model::Event;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'EVCenter::Base::Event' );

__PACKAGE__->meta->make_immutable;

1;
