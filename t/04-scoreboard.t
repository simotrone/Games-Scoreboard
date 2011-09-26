#!perl -T

use Test::More;

BEGIN {
	use_ok('Games::Scoreboard') || print "Oh noes!\n";
}

diag( "Testing Games::Scoreboard $Games::Scoreboard::VERSION, Perl $], $^X" );

ok( my $sb = Games::Scoreboard->new(), 'Scoreboard created.' );
isa_ok( $sb, 'Games::Scoreboard');
is( $sb->players->size, 0, 'Scoreboard has no players.' );

for(qw/Roger Minnie Pluto Pippo/) {
	my $player = Games::Scoreboard::Player->new( name => $_ );
	is( $sb->add_player($player), 1, "Insert $_ in scoreboard.");
}
is( $sb->players->size, 4, 'Scoreboard has four players now.' );

ok( my $ordered = $sb->order_players('name',1), 'Ordered players by name' );
is( $ordered->[0]->name,  'Minnie', 'The first player in alphabetic order is Minnie' );
is( $ordered->[-1]->name, 'Roger',  'The last player in alphabetic order is Roger' );

done_testing();
