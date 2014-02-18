use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::WS::Event;

ok( request('/ws/event')->is_success, 'Request should succeed' );
done_testing();
