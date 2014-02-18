use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::WebService;

ok( request('/webservice')->is_success, 'Request should succeed' );
done_testing();
