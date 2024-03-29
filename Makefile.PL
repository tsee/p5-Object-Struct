use 5.008001;
use strict;
use warnings;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
my $name = 'Object::Struct';
my $define = '';
if (grep {/--debug/} @ARGV) {
  $define = '-Wall -Wextra -O0 -g';
}
else {
  $define = '-O3 -DNDEBUG';
}

(my $file = $name . ".pm") =~ s/::/\//g;

WriteMakefile(
    NAME              => $name,
    VERSION_FROM      => "lib/$file", # finds $VERSION
    PREREQ_PM         => {
      'ExtUtils::ParseXS' => '2.2201',
      'Test::More' => '0.88',
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => "lib/$file", # retrieve abstract from module
       AUTHOR         => 'Steffen Mueller <smueller@cpan.org>') : ()),
    LIBS              => [''],
    DEFINE            => $define,
    INC               => '-I.',
    OBJECT            => '$(O_FILES)', # link all the C files too
);

