#!perl -T

use Test::More;

BEGIN {
	use_ok('Games::Scoreboard::Score') || print "Oh noes!\n";
}

ok( my $score  = Games::Scoreboard::Score->new() , 'A new default score.' );

ok( my $score0 = Games::Scoreboard::Score->new(
		rank     => 1,
		points   => 100,
		datetime => DateTime->now(),
	) , 'A new full created score.' );
is( $score0->rank,   1,   'Rank is ok' );
is( $score0->points, 100, 'Points are ok' );
isa_ok($score0->datetime, 'DateTime');

# Testing coerce
ok( my $score1 = Games::Scoreboard::Score->new(
		datetime => 1
	), 'A new score with datetime coercion (epoch 1)' );
is( $score1->datetime->ymd , '1970-01-01', 'Setting w/ epoch 1 - test Y:M:D');
is( $score1->datetime->hms , '00:00:01'  , 'Setting w/ epoch 1 - test H:M:S');
diag( $score1->datetime );

my $str = '2011-09-25T21:57:35';
ok( $score1->datetime($str), "Setting new datetime with string [$str]");
is( $score1->datetime->ymd , '2011-09-25', 'Setting w/ str - test Y:M:D');
is( $score1->datetime->hms , '21:57:35'  , 'Setting w/ str - test H:M:S');
diag( $score1->datetime );

done_testing(12);
