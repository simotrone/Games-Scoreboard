package Games::Scoreboard;

use 5.010;
use strict;
use warnings;
use Mouse;
use Set::Object;
use Games::Scoreboard::Player;

our $VERSION = '0.03';

has 'players' => (
	isa => 'Set::Object', is => 'rw',
	default => sub { Set::Object->new() },
	handles => {
		add_player  => 'insert',
		add_players => 'insert',
	},
);

sub order_players {
	my ($self, $attribute, $ascending) = @_;
	$attribute //= 'points';
	$ascending //= 0;

	return [] unless ( $self->players->size > 0 );
	my @unsorted = $self->players->members;

	my @list;
	given($attribute) {
		when(/^datetime$/) { @list = sort { DateTime->compare( $b->datetime, $a->datetime ) } @unsorted; }
		when(/^name$/)     { @list = sort { $b->$attribute cmp $a->$attribute } @unsorted; }
	        default            { @list = sort { $b->$attribute <=> $a->$attribute } @unsorted; }
	}
	@list = reverse(@list) if($ascending);

	return \@list;
}


1; # End of Games::Scoreboard
__END__
=head1 NAME

Games::Scoreboard - A Perl module to manage scoreboard, players and points.

=head1 VERSION

Version 0.03

=head1 SYNOPSIS

Games::Scoreboard help to manage a full scoreboard, with player(s) and score(s).

	use Games::Scoreboard;

	my $scoreboard = Games::Scoreboard->new();

	my $roger = Games::Scoreboard::Player->new( name => 'Roger Rabbit' );
	my $minnie = Games::Scoreboard::Player->new( name => 'Minnie' );
	my $pluto = Games::Scoreboard::Player->new( name => 'Pluto' );
	my $pluto_score = Games::Scoreboard::Score->new(
		points => 100, rank => 1
	);
	$pluto->add_score( $pluto_score );

	$scoreboard->add_players($roger, $minnie, $pluto);
	my $num_players = $scoreboard->players->size;
	# 3

	my $players = $scoreboard->order_players('points');
	my $first_player = $player->[0];

	$first_player->name;	# Pluto
	$first_player->points;	# 100


=head1 ATTRIBUTES

=head2 $scoreboard->players

=head1 METHODS

=head2 $scoreboard->add_player

=head2 $scoreboard->add_players

=head2 $scoreboard->order_players([$field, [$ascending]]);


=head1 AUTHOR

simotrone, C<< <simotrone at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-games-scoreboard at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-Scoreboard>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Games::Scoreboard


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Games-Scoreboard>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Games-Scoreboard>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Games-Scoreboard>

=item * Search CPAN

L<http://search.cpan.org/dist/Games-Scoreboard/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 simotrone.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
