use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::GUI::Authenticate;

ok( request('/gui/authenticate')->is_success, 'Request should succeed' );
done_testing();
