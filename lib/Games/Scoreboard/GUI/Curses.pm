package Games::Scoreboard::GUI::Curses;

use 5.010;
use strict;
use warnings;
use Curses::UI;
use DateTime;
use DateTime::Format::ISO8601;
use Games::Scoreboard;
use Carp;

# Constructor 
# required: scoreboard
# my $gui = Games::Scoreboard::GUI::Curses->new( scoreboard => Games::Scoreboard->new() );
sub new {
	my ($class,%attr) = @_;
	my $self = {
		'-gui_debug' => 0,
		'-gui_ascii' => 0,
		'-gui_color' => 1,
	};
	bless($self,$class);

	croak(__PACKAGE__.'->new() need a scoreboard attribute') unless( my $sb = $attr{'scoreboard'} );
	$self->scoreboard($sb);

	if( my $sw = $attr{'save_way'} ) {
		croak(__PACKAGE__.'->new() want a CODE ref for the save_way attribute') unless( ref $sw eq 'CODE' );
		$self->save_way($sw);
	}

	# Setting main gui default options (see $self->cui)
	$self->{'-gui_debug'} = $attr{'debug'} if( defined($attr{'debug'}) );
	$self->{'-gui_ascii'} = $attr{'ascii'} if( defined($attr{'ascii'}) );
	$self->{'-gui_color'} = $attr{'color'} if( defined($attr{'color'}) );

	return $self;
}

# $gui->run(); # Setup and run mainloop.
sub run {
	my $self = shift;
	my $cui  = $self->cui;
	$self->gui_setup();
	$cui->mainloop();
	return $self;
}

# $gui->scoreboard([$valore]); # REQUIRED. Setter/getter for data struct.
sub scoreboard {
	my ($self, $sbref) = @_;
	if($sbref) {
		croak(__PACKAGE__.'->scoreboard attribute must be a Games::Scoreboard.') unless(ref $sbref eq 'Games::Scoreboard');
		$self->{scoreboard} = $sbref;
	}
	return $self->{scoreboard};
}

# $gui->save_way( sub { ...code-to-save... } ); # Set/get the procedure to save.
sub save_way {
	my ($self, $save_way) = @_;
	if($save_way) {
		croak(__PACKAGE__.'->save_way attribute must be a CODE ref indeed '.(ref $save_way)) unless(ref $save_way eq 'CODE');
		$self->{save_way} = $save_way;
	}
	return $self->{save_way};
}


#############################
### Costruzione della GUI ###
#############################
sub gui_setup {
	my $self = shift;

	# Create widgets
	my $cui = $self->cui;
	my $menu_widget = $self->menu;
	my $sb_window   = $self->scoreboard_window;
	my $form_window = $self->form_window;
	$self->players_list();

	# Key bindings
	$cui->set_binding( sub { $menu_widget->focus() },    "\cX" );
	$cui->set_binding( sub { $self->save_scoreboard() }, "\cS" );
	$cui->set_binding( sub { $sb_window->focus() },      "\cA" );
	$cui->set_binding( sub { $form_window->focus() },    "\cB" );

	return $self;
}

sub save_scoreboard {
	my ($self) = @_;
	my $cui = $self->cui;

	unless($self->save_way) {
		$self->status_warning('Impossibile to save data.',2);
		return $self;
	}
	$cui->status('Saving data...');
	$self->save_way->();
	$cui->nostatus;

	$self->status_warning('Data saved.')->menu->focus();
	return $self;
}

sub show_player_data {
	my ($self, $player) = @_;
	my $name   = $player->name;
	my $scores = $player->order_scores();

	my $msg = "$name\n\n";
	$msg .= sprintf(
		"%4d. %10s pts %30s\n",
		$_->rank,
		$_->points,
		$_->datetime->strftime("%a %d %b %Y %H:%M")
	) for (@$scores);

	$self->cui->dialog(
		-title   => $name.' stats',
		-message => $msg,
	);

}

# Retrieve selected player data
sub player_selected {
	my ($self, $listbox) = @_;
	my ($selected_player) = $listbox->get();
	my $sb = $self->cui->userdata();
	unless($sb->players->size > 0) {
		$self->status_warning('No player in list.',1);
		return;
	}
	my ($player_object) = grep { $_->name eq $selected_player } $sb->players->members;
	$self->show_player_data($player_object);
}

# Draw player list (in scoreboard_window)
sub players_list {
	my $self = shift;

	my $win = $self->scoreboard_window;
	$win->delete('players_list') if( $win->getobj('players_list') );

	my @names;
	my %labels;
	my $cui = $self->cui;
	foreach my $p (@{$cui->userdata()->order_players('points')}) {
		push @names, $p->name;
		$labels{$p->name} = sprintf(
			"%4d. %-20s %10s pts %30s",
			$p->rank,
			$p->name,
			$p->points,
			$p->datetime->strftime("%a %d %b %Y %H:%M"),
		);
	}

	$win->add(
		'players_list', 'Listbox',
		-values     => [@names],
		-labels     => {%labels},
		-ipad       => 1,
#		-vscrollbar => 1,
		-onchange   => sub { $self->player_selected(@_) },
	);
	$win->draw();
}

# Gestione eventuale per mancanza di dati (per ora lo fa elegantemente Listbox)
#if($cui->userdata()->players->size < 1) {
#	$win->add(
#		'empty_players_list', 'Label',
#		-text => 'No record available.'
#	);
#}

sub cui {
	my $self = shift;

	unless($self->{cui}) {
		my $cui = Curses::UI->new(
			-clear_on_exit => 1,
			-color_support => $self->{'-gui_color'},
			-debug         => $self->{'-gui_debug'},
			-compat        => $self->{'-gui_ascii'},
		);
		$cui->userdata($self->scoreboard);
		$cui->set_binding( sub { exit() }, "\cQ" );
		$self->{cui} = $cui;
	}
	return $self->{cui};
}

sub menu {
	my $self = shift;

	unless($self->{menu_widget}) {
		my $file_menu = [
			{ -label => 'Save  [^S]', -value => sub { $self->save_scoreboard() }},
			{ -label => '----------', -value => sub {} },
			{ -label => 'Exit  [^Q]', -value => sub { exit(0) }  }
		];

		my $focus_menu = [
			{ -label => 'Scoreboard [^A]', -value => sub { $self->scoreboard_window->focus() } },
			{ -label => 'Add record [^B]', -value => sub { $self->form_window->focus() } },
		];

		my $main_menu = [
			{-label => 'File',  -submenu => $file_menu },
			{-label => 'Focus', -submenu => $focus_menu },
		];

		my $menu = $self->cui->add(
			'menu', 'Menubar',
			-menu => $main_menu,
		);
		$self->{menu_widget} = $menu;
	}
	return $self->{menu_widget};
}

sub scoreboard_window {
	my $self = shift;

	unless($self->{scoreboard_window}) {
		my $cui = $self->cui;

		my $win = $cui->add(
			'scoreboard_window', 'Window',
			-title     => 'Scoreboard',
			-border    => 1,
			-bfg       => 'red',
			-y         => 1,
			-padbottom => 10,
		);

		$self->{scoreboard_window} = $win;
	}

	return $self->{scoreboard_window};
}

sub form_window {
	my $self = shift;

	unless($self->{form_window}) {
		my $cui = $self->cui;

		my $win = $cui->add(
			'form_window', 'Window',
			-title  => 'Add record',
			-bfg    => 'blue',
			-border => 1,
			-y      => -1,
			-height => 10,
		);
		$self->form_fields($win);

		$self->{form_window} = $win;
	}
	return $self->{form_window};
}

sub form_fields {
	my ($self,$form_window) = @_;

	my $row = 1;
	my %field_opts = (
		-sbborder  => 1,
		-showlines => 1,
		-width     => 20,
		-x         => 9,
	);
	# Create Label + TextEntry per $player->attribute
	foreach my $name (qw{name points rank}) {
		# TODO: think about calendar for datetime
		$form_window->add(
			"label_$name", 'Label',
			-text => ucfirst($name),
			-y    => $row,
		);
		$form_window->add(
			$name, 'TextEntry', %field_opts,
			-y         => $row,
			-onchange  => sub { $self->field_warn($name, @_) },
		);
		$form_window->add(
			"warn_$name", 'Label',
			-y         => $row++,
			-x         => 30,
		);
	}

	# begin datetime field
	$form_window->add('label_datetime', 'Label', -text => 'Datetime', -y => $row);

	my $x = 9;
	$form_window->add(undef, 'Label', -text => '[', -y => $row, -x => $x++);
	foreach my $f (qw/dd mm yyyy/) {
		my $ln = length($f);
		$form_window->add(
			"datetime_$f", 'TextEntry', %field_opts,
			-y         => $row,
			-x         => $x,
			-width     => $ln,
			-maxlength => $ln,
			-sbborder  => 0,
			-showoverflow => 0,
#			-onchange  => sub {
#				my $field = shift;
#				( $self->field_warn("datetime_$f",$field) && $form_window->focus_next() )
#					if(length($field->get()) == $ln);
#			},
			# focus_next() is implemented in Curses::UI::Container.
		);
		$x += $ln;
		last if($f =~ m/yyyy/);
		$form_window->add(undef, 'Label', -text => '-', -y => $row, -x => $x++);
	}
	$form_window->add(undef, 'Label', -text => ']', -y => $row, -x => $x++);

	$form_window->add(
		'calendar_button', 'Buttonbox',
		-y => $row,
		-x => $x,
		-width => 1,
		-buttons => [
			{
				-label => 'c',
				-value => 1,
				-onpress => sub{
					my $date = $self->cui->calendardialog();
					return unless defined $date;
					my($yy,$mm,$dd) = split('-',$date);
					$form_window->getobj('datetime_dd')->text($dd);
					$form_window->getobj('datetime_mm')->text($mm);
					$form_window->getobj('datetime_yyyy')->text($yy);
				},
			}
		],
	);
	$x++;

	$form_window->add(undef, 'Label', -text => '[', -y => $row, -x => $x++);
	foreach my $f (qw/HH MM/) {
		my $ln = length($f);
		$form_window->add(
			"datetime_$f", 'TextEntry', %field_opts,
			-y         => $row,
			-x         => $x,
			-width     => $ln,
			-maxlength => $ln,
			-sbborder  => 0,
			-showoverflow => 0,
#			-onchange  => sub {
#				my $field = shift;
#				( $self->field_warn("datetime_$f",$field) && $form_window->focus_next() )
#					if(length($field->get()) == $ln);
#			},
			# focus_next() is implemented in Curses::UI::Container.
		);
		$x += $ln;
		last if($f =~ m/MM/);
		$form_window->add(undef, 'Label', -text => ':', -y => $row, -x => $x++);
	}
	$form_window->add(undef, 'Label', -text => ']', -y => $row, -x => $x);

	# end datetime field

	$form_window->add(
		undef, 'Buttonbox',
		-y       => $row+1,
		-x       => 2,
		-buttons => [
			{
				-label   => '< Submit >',
				-value   => 'submit',
				-onpress => sub {$self->submit_form(@_)}
			},
			{
				-label   => '< Cancel >',
				-value   => 'cancel',
				-onpress => sub {$self->cancel_form(@_)}
			},
		],
	);

	return $form_window;
}

# Helper warning while you're digiting.
sub field_warn {
	my ($self,$name, $field) = @_;

	my $form  = $self->form_window;
	my $warn  = $form->getobj("warn_$name");
	my $typed = $field->get();

	my $flag = 0;

	# Set warning text
	given($name) {
		when(/^name$/)          {
			($typed =~ m/^\S.*$/)
				? $warn->text('') && ($flag = 1)
				: $warn->text('A non-blank name is mandatory.');
		}
		when(/^(points|rank)$/) {
			($typed =~ m/^\d*$/)
				? $warn->text('') && ($flag = 1)
				: $warn->text('Only integer numbers allowed.');
		}
# interesting but useless
#		when(/^datetime_(.+)$/) {
#			given($1) {
#				when(/dd/) { $flag = ($typed >= 1 and $typed <= 31) ? 1 : 0; }
#				when(/mm/) { $flag = ($typed >= 1 and $typed <= 12) ? 1 : 0; }
#				when(/HH/) { $flag = ($typed >= 0 and $typed <= 24) ? 1 : 0; }
#				when(/MM/) { $flag = ($typed >= 0 and $typed <= 60) ? 1 : 0; }
#			}
#		}
	}

	# Filter datetime_* fields for following getobj method.
	$name =~ s/(datetime).+/$1/;

	# Set warning alarm color
	my $label = $form->getobj("label_$name");
	$flag ? $label->set_color_fg('green') : $label->set_color_fg('red') ;

	return $flag;
}

sub cancel_form {
	my ($self) = @_;
	my $form = $self->form_window;
	for (qw/name points rank/, map{"datetime_$_"}(qw/dd mm yyyy HH MM/) ) {
		$form->getobj($_)->text('')        if($form->getobj($_));
		$form->getobj("warn_$_")->text('') if($form->getobj("warn_$_"));
		$form->getobj("label_$_")->set_color_fg('white') if($form->getobj("label_$_"));
	}
	$form->getobj('name')->focus();
	return $self;
}

sub submit_form {
	my ($self) = @_;
	my $form = $self->form_window;
	my $values = {};
	for (qw/name points rank/, map{"datetime_$_"}(qw/dd mm yyyy HH MM/) ) {
		# if $attr->TextEntry exists get value else undef
		$values->{$_} = $form->getobj($_) ? $form->getobj($_)->get() : undef;
	}

	# add_to_scoreboard return undef if it fails.
	unless( $self->add_to_scoreboard($values) ) {
		$form->focus();
		return $self;
	}

	# if add_to_scoreboard is ok, clean form and update players_list
	$self->cancel_form->players_list();
	return $self;
}

sub add_to_scoreboard {
	my ($self, $fields) = @_;
	my $cui = $self->cui;

	if( !defined($fields->{name}) || $fields->{name} =~ m/^\s*$/ ) {	# mandatory field
		$cui->error("The `name' field is mandatory!");
		return undef;
	}
	my $sb = $cui->userdata();

	my @already_in = grep { $_->name eq $fields->{name} } $sb->players->members;

	# If record exists, take the old record else create new.
	my $player_obj = (@already_in > 0)
		? shift(@already_in)
		: Games::Scoreboard::Player->new(name => $fields->{name});
	
	my $score_obj = Games::Scoreboard::Score->new();

	foreach my $attr (keys %$fields) {
		# Run through the fields, take value and put if obj has setter.
		if( (my $value = $fields->{$attr}) && $score_obj->can($attr) ) {
			eval { $score_obj->$attr($value) };
			if($@) { $self->status_warning($@,2); return undef }
		}
	}

	foreach (['year','yyyy'],['day','dd'],['month','mm'],['hour','HH'],['minute','MM']) {
		my $set = "set_".$_->[0];	# DateTime setter
		my $key = "datetime_".$_->[1];	# field key name
		eval { $score_obj->datetime->$set($fields->{$key}) } if($fields->{$key});
		if($@) { $self->status_warning($@,2); return undef }
	}

	$player_obj->add_score($score_obj);
	$sb->add_player($player_obj);
	return 1;
}

# $self->status_warning($message,$sec) 
# Status popup with $message for $sec seconds (default 1)
sub status_warning {
	my ($self, $message, $sec) = @_;
	$sec //= 1;
	my $cui = $self->cui;

	$cui->status($message);
	sleep $sec;
	$cui->nostatus;

	return $self;
}

# Dialogs
sub exit_dialog {
	my $self = shift;
	my $cui = $self->cui;
	my $return = $cui->dialog(
		-message => "Do you really want to quit?",
		-title   => "Are you sure?",
		-buttons => ['yes','no'],
	);
	exit(0) if $return;
}

sub debug_dialog {
	my ($self,$data) = @_;
	my $cui = $self->cui;
	use Data::Dumper;
	$cui->dialog(-message => Dumper($data));
	return $self;
}

1;
__END__
