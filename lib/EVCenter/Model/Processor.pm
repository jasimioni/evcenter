package EVCenter::Model::Processor;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( 
    class       => 'EVCenter::Base::Event::Processor',
    constructor => 'new',
);

__PACKAGE__->meta->make_immutable;

1;
