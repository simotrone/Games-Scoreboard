#!perl -T

use Test::More;

BEGIN {
	use_ok('Games::Scoreboard::Player') || print "Oh noes!\n";
}

ok( my $pippo = Games::Scoreboard::Player->new( name => 'Pippo' ), 'Player Pippo created' );
isa_ok( $pippo->scores ,'Set::Object' );
ok( my $aref = $pippo->order_scores(), 'Pippo order his 0 scores' );
is( ref $aref, 'ARRAY', 'order_scores() return an arrayref' );
is( scalar @$aref, 0, 'Pippo has 0 scores');

# Default data for pippo
my %defaults = ( rank => 9999, points => 0, datetime => undef );
for (keys %defaults) {
	if( $_ eq 'datetime') {
		isa_ok( $pippo->$_, 'DateTime' );
		next;
	}
	is( $pippo->$_, $defaults{$_}, "Pippo has default $_" );
}
is( $pippo->scores->size, 0, 'Pippo has no scores' );

done_testing(10);
