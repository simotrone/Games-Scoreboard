#!perl -T

use Test::More;
use DateTime;
use Data::Dumper;

BEGIN {
    use_ok( 'Games::Scoreboard::Model::XML' ) || print "Bail out!\n";
}

my @files = map { "t/xml_scoreboard_test_$_.xml" } (1..3);

# writing test

my $sb = Games::Scoreboard->new();

# Write test #1
my $xmlw = Games::Scoreboard::Model::XML->new( scoreboard => $sb );
isa_ok( $xmlw->scoreboard , 'Games::Scoreboard' );
$xmlw->filepath($files[0]);
ok( $xmlw->write() , "Writing empty scoreboard - $files[0] saved." );

# Write test #2
my @players = map { Games::Scoreboard::Player->new( name => $_ ) } ( 'Pinco Pallino', 'Pippo', 'Pluto', 'Sempronio');
$sb->add_players(@players);
isa_ok($sb->players, 'Set::Object' );
is( $sb->players->size , 4, 'There are 4 players in scoreboard.' );
$xmlw->filepath($files[1]);
ok( $xmlw->write() , "Writing only players scoreboard - $files[1] saved." );

# Write test #3
my $dt = DateTime->now();

my @scores_description = (
	{ rank => 1,  points => 50,  datetime => $dt },                               # 0
	{ rank => 2,  points => 90,  datetime => $dt->clone->subtract(months => 1) }, # 1
	{ rank => 3,  points => 80,  datetime => $dt->clone->subtract(days   => 1) }, # 2
	{ rank => 30, points => 100, datetime => $dt->clone->subtract(days   => 2) }, # 3
	{ rank => 31, points => 99,  datetime => $dt->clone->subtract(days   => 3) }, # 4
	{ rank => 7,  points => 100, datetime => $dt },                               # 5
	{ rank => 8,  points => 90,  datetime => $dt },                               # 6
	{ rank => 9,  points => 80,  datetime => $dt },                               # 7
);

my @scores = map { Games::Scoreboard::Score->new( %$_ ) } @scores_description;

$players[0]->add_scores($scores[0],$scores[1],$scores[4]); # Pinco Pallino
$players[1]->add_scores($scores[5],$scores[2]);            # Pippo
$players[2]->add_scores($scores[6],$scores[3]);            # Pluto
$players[3]->add_scores($scores[7]);                       # Sempronio

$xmlw->filepath($files[2]);
ok( $xmlw->write() , "Writing complete scoreboard - $files[2] saved." );

###############
# reading test

my @tags     = ('[Empty]', '[Just Players]', '[Complete]');
my @test_sub = (
	# No scores to test
	undef,
	# Just players - Only 0 scores for each player
	sub {
		my ($xml,$tag) = @_;
		check_player_scores($tag, $_, 0) for ($xml->scoreboard->players->members);
		return 1;
	},
	# Players + scores - Many scores to test for each player
	sub {
		my ($xml,$tag) = @_;
		foreach my $p ($xml->scoreboard->players->members) {
			check_player_scores($tag, $p, 3, [50,90,99]) if ( $p->name =~ /Pinco Pallino/ );
			check_player_scores($tag, $p, 2, [80,100])   if ( $p->name =~ /Pippo/ );
			check_player_scores($tag, $p, 2, [100,90])   if ( $p->name =~ /Pluto/ );
			check_player_scores($tag, $p, 1, [80])       if ( $p->name =~ /Sempronio/ );
		}
		return 1;
	},
);

my @array_for_testing = (
#       [ xml_files, players , tags,     scores_test  ]
#                    expected            subroutine
	[ $files[0],  0,       $tags[0], $test_sub[0] ],  # reading empy file
	[ $files[1],  4,       $tags[1], $test_sub[1] ],  # reading just players data (no score)
	[ $files[2],  4,       $tags[2], $test_sub[2] ],  # reading complete xml file (player + scores)
);

foreach my $values (@array_for_testing) {
	my($file, $size, $tag, $scores_test_subroutine) = @$values;

	my $xmlr = Games::Scoreboard::Model::XML->new(
		scoreboard => $sb,
		filepath   => $file,
	);
	ok( $xmlr->read() ,                          "$tag XML in $file in scoreboard." );
	is( $xmlr->scoreboard->players->size, $size, "$tag There are $size players in scoreboard now." );
	
#	diag Dumper $xmlr;

	$scores_test_subroutine->($xmlr,$tag) if(defined($scores_test_subroutine));
}

sub check_player_scores {
	my ($tag, $player, $scores_exptected, $points_expected ) = @_;

	my $name        = $player->name;
	my $real_scores = $player->scores->size;

	is( $real_scores , $scores_exptected, "$tag $name has $scores_exptected scores." );

	return unless $points_expected;
	my @real_points = map { $_->points } $player->scores->members;
	ok( $_ ~~ @$points_expected, "$tag   $name has $_ points in a score." ) for @real_points;
}

done_testing(29);
