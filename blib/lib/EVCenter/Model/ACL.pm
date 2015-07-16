package EVCenter::Model::ACL;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( 
    class       => 'EVCenter::Base::ACL',
    constructor => 'new',
);

__PACKAGE__->meta->make_immutable;

1;
