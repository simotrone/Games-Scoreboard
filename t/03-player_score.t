#!perl -T

use Test::More;

BEGIN {
	use_ok('Games::Scoreboard::Player') || print "Oh noes!\n";
	use_ok('Games::Scoreboard::Score') || print "Oh noes!\n";
}

ok( my $pluto = Games::Scoreboard::Player->new( name => 'Pluto' ), 'Player Pluto created' );
is( $pluto->scores->size, 0, 'Pluto has no scores' );

# Scores generate
# rank => point
my $dt0 = DateTime->now();
my %rp; 
for (1..10) { $rp{$_} = $_*10 };
my @scores;
foreach my $rank (keys %rp) {
	my $dt = $dt0->clone()->subtract( days => $rp{$rank} );
	my $score = Games::Scoreboard::Score->new(
		rank => $rank, points => $rp{$rank},
		datetime => $dt,
	);
	push @scores, $score;
}
# Situation: in @scores there are 10 Score (more rank, more points, more old)
# rank:     X
# points:   X*10
# datetime: now - (X*10) days
is( $pluto->add_scores(@scores), 10, 'Add 10 scores to Pluto' );


# Test no record duplication - add_scores return 0
my($dup0, $dup1) = @scores;
is( $pluto->add_scores($dup0, $dup1), 0, 'The two scores are in yet.' );
is( $pluto->add_score($scores[3]), 0, 'The forth score are in yet.' );

my($first,$last,$order);

# default order
ok( $order = $pluto->order_scores() , 'Pluto scores with default order (datetime descending).' );
ok( $first  = $order->[0],  'We have recentest score' );
ok( $last   = $order->[-1], 'We have oldest score' );
is( DateTime->compare($first->datetime,$last->datetime), 1, 'Datetime recent > Datetime last' );
# diag( 'Recent score: ', $first->datetime );
# diag( 'Last score:   ', $last->datetime );
is( $first->rank,    1, 'The recent score has rank 1' );
is( $first->points, 10, 'The recent score has 10 points' );
is( $last->rank,     10, 'The oldest score has rank 10' );
is( $last->points,  100, 'The oldest score has 100 points' );

# points ascending order
ok( $order = $pluto->order_scores('points',1) , 'Pluto scores with points ascending order.' );
ok( $first  = $order->[0],  'We have score with less points.' );
ok( $last   = $order->[-1], 'We have score with more points.' );
is( DateTime->compare($first->datetime,$last->datetime), 1, 'Datetime score-less-points > score-more-points' );
is( $first->rank,    1, 'The first score has rank 1' );
is( $first->points, 10, 'The first score has 10 points' );
is( $last->rank,     10, 'The last score has rank 10' );
is( $last->points,  100, 'The last score has 100 points' );

# rank descending order
ok( $order = $pluto->order_scores('rank') , 'Pluto scores with rank descending order.' );
ok( $first  = $order->[0],  'We have score with more rank.' );
ok( $last   = $order->[-1], 'We have score with less rank.' );
is( DateTime->compare($first->datetime,$last->datetime), -1, 'Datetime score-more-rank < score-less-rank' );
is( $first->rank,    10, 'The first score has rank 10' );
is( $first->points, 100, 'The first score has 100 points' );
is( $last->rank,      1, 'The last score has rank 1' );
is( $last->points,   10, 'The last score has 10 points' );

done_testing(31);
