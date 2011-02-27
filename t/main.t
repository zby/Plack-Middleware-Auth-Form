use strict;
use warnings;

use Test::More;
use Test::WWW::Mechanize::PSGI;
my $app = do 't/app.psgi' || warn $! ? "Cannot find 't/app.psgi: $!" : "Cannot compile 't/app.psgi': $@";

my $mech = Test::WWW::Mechanize::PSGI->new( app => $app );
$mech->get( '/some_page' );
$mech->follow_link_ok( { text => 'login' } );
$mech->submit_form_ok( {
        with_fields => {
            username => 'aaa',
            password => 'bbb',
        }
    }
);
$mech->content_contains( 'Wrong username or password', 'Wrong username or password' );
$mech->submit_form_ok( {
        with_fields => {
            username => 'aaa',
            password => 'aaa',
        }
    }
);
$mech->content_contains( 'Hi aaa', 'login passed, user_id filled in' );
is( $mech->uri->path, '/some_page', 'Redirect after login' );
$mech->submit_form_ok( { form_name => 'logout_form' } );
$mech->content_contains( '<a href="/login">login</a>', 'user logged out' );

done_testing;
