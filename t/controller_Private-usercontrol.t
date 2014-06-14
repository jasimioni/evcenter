use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::Private::usercontrol;

ok( request('/private/usercontrol')->is_success, 'Request should succeed' );
done_testing();
