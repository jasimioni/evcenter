use strict;
use warnings;
use Test::More;


use Catalyst::Test 'EVCenter';
use EVCenter::Controller::Private::Event;

ok( request('/private/event')->is_success, 'Request should succeed' );
done_testing();
