package Games::Scoreboard::Player;

use 5.010;
use Mouse;
use Set::Object;
use Games::Scoreboard::Score;

has 'name'   => ( isa => 'Str', is => 'ro', required => 1 );
has 'scores' => (
	isa => 'Set::Object', is => 'rw',
	default => sub { Set::Object->new() },
	handles => {
		add_score  => 'insert',
		add_scores => 'insert'
	}
);

sub order_scores {
	my ($self, $attribute, $ascending) = @_;

	my @allowed = qw/rank points datetime/;
	$attribute = 'datetime' unless ( defined($attribute) && $attribute ~~ @allowed );
	$ascending //= 0;

	return [] unless ( $self->scores->size > 0 );
	my @unsorted_scores = $self->scores->members;

	my @list;
	given($attribute) {
		when(/^datetime$/) { @list = sort { DateTime->compare($b->datetime, $a->datetime) } @unsorted_scores; } 
		default            { @list = sort { $b->$attribute <=> $a->$attribute } @unsorted_scores; }
	}
	@list = reverse(@list) if($ascending);

	return \@list;
}

# Return the more recent Score object or undef
sub _last_score {
	my $self = shift;
	my $ordered_scores = $self->order_scores();

	return undef unless ( scalar(@$ordered_scores) > 0 );
	return $ordered_scores->[0];
}
# Return a default Score object
has '_default_score' => (
	isa     => 'Games::Scoreboard::Score',
	is      => 'ro',
	default => sub { Games::Scoreboard::Score->new() },
);

# Return the more recent rank or default
sub rank {
	my $self = shift;

	return $self->_default_score->rank unless $self->_last_score();
	return $self->_last_score()->rank;
}
# Ritorna il punteggio piu' recente
sub points {
	my $self = shift;
	return $self->_default_score->points unless $self->_last_score();
	return $self->_last_score()->points;
}
# Ritorna il datetime piu' recente
sub datetime {
	my $self = shift;
	return $self->_default_score->datetime unless $self->_last_score();
	return $self->_last_score()->datetime;
}

1;
__END__
=head1 NAME

Games::Scoreboard::Player - A Player object in a Scoreboard world.

=head1 SYNOPSIS

	my $player = Games::Scoreboard::Player->new( name => 'Pippo' );

	if($player->scores->size > 0) {
		# player have scores
	}

=head1 ATTRIBUTES

=head2 $player->name

Mandatory attribute for Player object.

=head2 $player->scores

Return a Set::Object object with the player Scores.

You can use all the Set::Object methods to manipulate the
player scores.

	$player->scores->size
	$player->scores->members
	...


=head1 METHODS

=head2 $player->add_score( $score )

=head2 $player->add_scores([ $score0, $score1, ... ])
	
Add one or more score object (Games::Scoreboard::Score) to $player.

This method clone the Set::Object->insert behaviour, so it DON'T 
duplicate same scores.

	$player->add_scores( $sc0, $sc1, $sc2, $sc0 )
	# add just 3 scores

Return the number of stored items.


=head2 $player->order_scores([$field, [$ascending]])

Return a Games::Scoreboard::Score objects arrayref with elements ordered
by $field descending.

$field is the name of Score attribute that you want to use to order
(default is `datetime` for $score->datetime attribute).

$ascending is a boolean value to order in ascending order (default is
$ascending = 0, descending order).

	my $ordered_scores = $player->order_scores();
	# return a list of scores objects order by datetime descending
	
	my $ordered_scores_by_points = $player->order_scores('points', 1);
	# return a list order by points ascending.

Return an empty arrayref if $player->scores have no items inside.

=head2 $player->points
=head2 $player->rank
=head2 $player->datetime

These three methods are three shortcuts to the current player values.
They return respectively each value from the more recent Player Score object.

If a last score is not in, they return the Score default values.

=head1 AUTHOR

simotrone, C<< <simotrone at gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 simotrone.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
