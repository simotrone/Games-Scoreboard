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
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Games-Scoreboard-*' },
);
