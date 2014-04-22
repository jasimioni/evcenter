use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::GUI::Auth;

ok( request('/gui/auth')->is_success, 'Request should succeed' );
done_testing();
