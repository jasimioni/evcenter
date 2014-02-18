use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::WebServices;

ok( request('/webservices')->is_success, 'Request should succeed' );
done_testing();
