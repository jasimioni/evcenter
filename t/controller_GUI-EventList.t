use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::GUI::EventList;

ok( request('/gui/eventlist')->is_success, 'Request should succeed' );
done_testing();
