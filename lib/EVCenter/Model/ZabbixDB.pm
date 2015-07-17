package EVCenter::Model::ZabbixDB;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( 
    class       => 'EVCenter::Base::ZabbixDB',
    constructor => 'new',
);

1;
