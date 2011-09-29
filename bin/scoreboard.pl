#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Games::Scoreboard::Model::XML;
use Games::Scoreboard::GUI::Curses;

our $VERSION = 0.01;

use Getopt::Long;
# Managing options
my %options = (
	'debug' => 0,
	'ascii' => 0,
	'color' => 1,
	'filepath' => 'scoreboard.xml',
);
GetOptions(
	'debug'  => \$options{debug},
	'ascii'  => \$options{ascii},
	'color!' => \$options{color},
	'file=s'   => \$options{filepath},
);

# filename in $ARGV[0] take precedence on --file= option.
my $filepath = $ARGV[0] || $options{filepath};
unless( -e $filepath ) {
	open(my $fh, '>', $filepath) || croak("Problem to write the $filepath default file.");
	print $fh '<scoreboard></scoreboard>';
	close($fh);
}


# Managing data for GUI
my $xml = Games::Scoreboard::Model::XML->new(filepath => $filepath);
my $sb = $xml->read->scoreboard;

# Set & start GUI
my $gui = Games::Scoreboard::GUI::Curses->new(
	scoreboard => $sb,
	save_way   => sub { $xml->write() },
	%options,
);
$gui->run;

exit(0);
__END__
=head1 NAME

scoreboard.pl

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

scoreboard.pl is the script that run the gui on Games::Scoreboard.

	$ scoreboard.pl
	# GUI starts
	
	$ scoreboard.pl -a --nocolor data/myfavouritegame.xml
	# launch GUI in ascii mode, no color, and getting data from file
	# 'data/myfavouritegame.xml'

	# It's identical to:
	$ scoreboard.pl -a --nocolor --file=data/myfavouritegame.xml
	


=head1 OPTIONS

You can launch the script with following options.

scoreboard.pl need a file where load and save data. You can pass the file name
as script argument or with --file= option (see lower). @ARGV take precedence on
option.

If no file is provided, scoreboard.pl use generic filename `scoreboard.xml' in
current directory. If the file doesn't exists, the script create it.

=head2 --debug

Is possibile enable debugging to track pressed keys or log errors.
The logs go in debug.out file in local directory.

Default is disabled.

=head2 --ascii

Usually you want your Curses widget drawed with fancy character. If you wantn't or
need simple chars, you can set ascii option. (See Curses::UI -compat option.)

Default is disabled.

=head2 --color / --nocolor

scoreboard.pl draw a colored GUI. If you want a white and black interface, throw
away colors with --nocolor (you are setting Curses::UI -color_support option).

Default is enable. (We want color!)

=head2 --file='myscoreboard.xml'

The script need a file to load data at start, and save data (if you want) when
session end.
It is possibile provide file as first command line argument ($ARGV[0]) or with this
options.

	$ scoreboard --file='file.xml'
	# or...
	$ scoreboard file.xml

If a file isn't provided, the script auto-create a scoreboard.xml file in the local
directory.

Default is "scoreboard.xml".


=head1 AUTHOR

simotrone, C<< <simotrone at gmail.com> >>


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 simotrone.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

