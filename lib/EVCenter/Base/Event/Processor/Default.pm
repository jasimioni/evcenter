package EVCenter::Base::Event::Processor::Default;

use Moose;
extends 'EVCenter::Base::Event::Processor::Common';
use Try::Tiny;
use common::sense;
use namespace::clean -except => 'meta';


1;