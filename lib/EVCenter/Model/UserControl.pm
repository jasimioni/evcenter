package EVCenter::Model::UserControl;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( 
    class       => 'EVCenter::Base::UserControl',
    constructor => 'new',
);

1;
