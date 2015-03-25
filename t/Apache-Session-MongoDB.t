# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Apache-Session-MongoDB.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use utf8;

use Test::More tests => 6;
BEGIN { use_ok('Apache::Session::MongoDB') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

SKIP: {

    unless ( defined $ENV{MONGODB_SERVER} ) {
        skip 'MONGODB_SERVER is not set', 4 unless ( $ENV{MONGODB_SERVER} );
    }
    my %h;

    ok(
        tie(
            %h, 'Apache::Session::MongoDB',
            undef, { host => $ENV{MONGODB_SERVER} }
        ),
        'New object'
    );

    my $id;
    ok( $id = $h{_session_id}, '_session_id is defined' );
    $h{some} = 'data';
    $h{utf8} = 'éàèœ';

    untie %h;

    my %h2;
    ok(
        tie(
            %h2, 'Apache::Session::MongoDB',
            $id, { host => $ENV{MONGODB_SERVER} }
        ),
        'Access to previous session'
    );

    ok( $h2{some} eq 'data', 'Find data' );
    ok( $h2{utf8} eq 'éàèœ', 'UTF string' );

    #binmode(STDERR, ":utf8");
    #print STDERR $h2{utf8}."\n";

    tied(%h2)->delete;

}
