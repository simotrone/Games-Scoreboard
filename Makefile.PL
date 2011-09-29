use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Games::Scoreboard',
    AUTHOR              => q{simotrone <simotrone@gmail.com>},
    VERSION_FROM        => 'lib/Games/Scoreboard.pm',
    ABSTRACT_FROM       => 'lib/Games/Scoreboard.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'Carp'       => 0,
	'Curses::UI' => 0,
	'DateTime'   => 0,
	'DateTime::Format::ISO8601' => 0,
	'IO::File'   => 0,
	'Mouse'      => 0,
	'Mouse::Util::TypeConstraints' => 0,
	'Set::Object' => 0,
	'XML::Parser' => 0,
	'XML::Writer' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Games-Scoreboard-*' },
);
