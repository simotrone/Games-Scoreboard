package Games::Scoreboard::Score;

use Mouse;
use Mouse::Util::TypeConstraints;
use DateTime;
use DateTime::Format::ISO8601;

subtype 'Games::Scoreboard::DateTime'
	=> as 'Object' => where { $_->isa('DateTime') };
coerce 'Games::Scoreboard::DateTime'
	=> from 'Num' => via { DateTime->from_epoch(epoch => $_) }
	=> from 'Str' => via { DateTime::Format::ISO8601->parse_datetime($_) };

has 'rank'     => ( isa => 'Int', is => 'rw', default => 9999 );
has 'points'   => ( isa => 'Int', is => 'rw', default => 0 );
has 'datetime' => (
	isa => 'Games::Scoreboard::DateTime', is => 'rw', required => 1,
	coerce => 1,
	default => sub { DateTime->now() }
);

1;
__END__
=head1 NAME

Games::Scoreboard::Score

=head1 SYNOPSIS

	use Games::Scoreboard::Score;

	my $default_score = Games::Scoreboard::Score->new();
	$default_score->rank		# 9999
	$default_score->points		# 0
	$default_score->datetime	# DateTime->now()

	my $score = Games::Scoreboard::Score-new(
		rank => 1,
		points => 100000,
	);

=head1 Attributes

All the attributes are getter and setter.

=head2 $sc->rank

If you wanna remember the rank corresponding to the points...

=head2 $sc->points

Get or set the score points.

=head2 $sc->datetime

This attribute allow manipulation as a DateTime object.

You can set the C<datetime> attribute as DateTime object, epoch and
ISO8601 string (see DateTime::Format::ISO8601).
