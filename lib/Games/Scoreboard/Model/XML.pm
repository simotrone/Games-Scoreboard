package Games::Scoreboard::Model::XML;

use Mouse;
use IO::File;
use XML::Writer;
use XML::Parser;
use Games::Scoreboard;

has 'filepath'   => ( isa => 'Str', is => 'rw', default => 'scoreboard.xml' );
has 'scoreboard' => (
	isa     => 'Games::Scoreboard',
	is      => 'rw',
	default => sub { Games::Scoreboard->new() },
);

# Write 'scoreboard' on 'filepath'
sub write {
	my $self = shift;

	my $fpath = $self->filepath;
	my $sb    = $self->scoreboard;

	my $output = new IO::File("> $fpath");
	my $w = new XML::Writer(
		OUTPUT      => $output,
		ENCODING    => 'utf-8',
		DATA_MODE   => 1,
		DATA_INDENT => 4
	);

#	$w->xmlDecl();
        $w->startTag('scoreboard');	# <scoreboard>
	foreach my $player (@{$sb->players}) {
					# <player name="">
		$w->startTag(
			'player',
			'name' => $player->name
		);
		foreach my $score (@{$player->scores}) {
					# <score points="" rank="" datetime="" />
			$w->emptyTag(
				'score',
				'points'   => $score->points,
				'rank'     => $score->rank,
				'datetime' => $score->datetime
			);
		}
		$w->endTag('player');	# </player>
	}
	$w->endTag('scoreboard');	# </scoreboard>
	$w->end();
	$output->close();
	return 1;
}

# read extract from 'filepath' and put in 'scoreboard'
# WARNING: When Games::Scoreboard::Model::XML->read() start the parsing it clean the $scoreboard->players attribute.
sub read {
	my $self = shift;

	my $fpath = $self->filepath;
	my $input = new IO::File("< $fpath");

	my $parser = XML::Parser->new(
		Handlers => {
			Init  => sub { $self->scoreboard->players->clear },
			Start => sub { $self->_start_tag_handler(@_) },
			End   => sub { $self->_end_tag_handler(@_) }
		} )->parse($input);
	$input->close();

	return $self;
}

has '_current_player' => (
	isa     => 'Games::Scoreboard::Player',
	is      => 'rw',
	clearer => 'clear_current_player'
);

sub _start_tag_handler {
	my ($self, $expat, $element, %attr) = @_;
	my $parent = $expat->current_element;

	# <player> elaboration
	if( $element eq 'player' && $parent eq 'scoreboard' && defined($attr{'name'}) ) {
		my $player = Games::Scoreboard::Player->new( name => $attr{'name'} );
		$self->_current_player($player);
		return;
	}

	# <score/> elaboration
	if( $element eq 'score' && $parent eq 'player' ) {
		my $score = Games::Scoreboard::Score->new(
			rank     => $attr{'rank'},
			points   => $attr{'points'},
			datetime => $attr{'datetime'}
		);
		$self->_current_player->add_score($score);
		return;
	}
}

sub _end_tag_handler {
	my ($self, $expat, $element) = @_;
	my $parent = $expat->current_element;
	
	# </player> elaboration
	if( $element eq 'player' && $parent eq 'scoreboard' ) {
		my $player = $self->_current_player; 
		$self->scoreboard->add_player($player);
		$self->clear_current_player;
		return;
	}
	return;
}

1;
__END__
=head1 NAME

Games::Scoreboard::Model::XML - Save in and load from file Scoreboard data structure.

=head1 SYNOPSIS

	my $xml = Games::Scoreboard::Model::XML->new(
		scoreboard => Games::Scoreboard->new(),
		filepath   => 'data/scoreboard.xml',
	);

	$xml->read;
	my $sb = $xml->scoreboard;
	# read from file and put the datastruct in $sb attribute
	
	# we can also...
	my $sb = $xml->read->scoreboard;
	
	$xml->write();
	# save the datastruct $sb in file - $xml->filepath.


=head1 ATTRIBUTES

=head2 $xml->scoreboard

Is a Games::Scoreboard object.

The package write from this attribute when copy in xml file, and put data here
when read from xml file.

WARNING: When Games::Scoreboard::Model::XML read from file and put data in
$xml->scoreboard attribute it clean the $xml->scoreboard attribute.
So, pay attention when you load data from file. ;-)

=head2 $xml->filepath

Is a string that point the path/to/file to write and read (when you save your
data structure or read it from xml file).


=head1 METHODS

=head2 $xml->write

Copy data structure in $xml->scoreboard in $xml->filepath as XML format.

=head2 $xml->read

Extract data structure from $xml->filepath (XML file) to $xml->scoreboard
(see Games::Scoreboard).

WARNING: As explained under the scoreboard attribute, read clear the scoreboard
attribute before load in it data from xml file. Pay attention, please.
