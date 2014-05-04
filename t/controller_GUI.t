use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::GUI;

ok( request('/gui')->is_success, 'Request should succeed' );
done_testing();
