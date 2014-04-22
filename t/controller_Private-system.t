use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::Private::system;

ok( request('/private/system')->is_success, 'Request should succeed' );
done_testing();
