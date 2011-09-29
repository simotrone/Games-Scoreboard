#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Games::Scoreboard::Model::XML;
use Games::Scoreboard::GUI::Curses;

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
	open(my $fh, '>', $filepath);
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

MouseHunt::Tracker - The great new MouseHunt::Tracker!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MouseHunt::Tracker;

    my $foo = MouseHunt::Tracker->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1


=head2 function2


=head1 AUTHOR

simotrone, C<< <simotrone at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mousehunt-tracker at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MouseHunt-Tracker>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MouseHunt::Tracker


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MouseHunt-Tracker>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MouseHunt-Tracker>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MouseHunt-Tracker>

=item * Search CPAN

L<http://search.cpan.org/dist/MouseHunt-Tracker/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 simotrone.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

