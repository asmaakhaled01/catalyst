use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Blog';
use Blog::Controller::Comments;

ok( request('/comments')->is_success, 'Request should succeed' );
done_testing();
