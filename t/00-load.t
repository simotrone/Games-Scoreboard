#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Games::Scoreboard' ) || print "Bail out!\n";
}

diag( "Testing Games::Scoreboard $Games::Scoreboard::VERSION, Perl $], $^X" );
