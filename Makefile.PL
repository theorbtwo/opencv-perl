#!/bin/env perl
use warnings;
use strict;
use ExtUtils::MakeMaker;
use ExtUtils::PkgConfig;
use Config;

# We actually only do this so that we get a *nice* error message, and
# use the static-method interface below.
ExtUtils::PkgConfig->find('opencv');

print "'Typemap typemap.dynamic not found' is normal, ignore it (it will be generated at make time).\n";
WriteMakefile(
              CC => 'g++',
              NAME => 'OpenCV',
              INC => ExtUtils::PkgConfig->cflags_only_I('opencv'),
              CCFLAGS => (ExtUtils::PkgConfig->cflags_only_other('opencv') .
                          $Config{ccflags} .
                          # Be extra paranoid, but unused parameters
                          # and variables are normal in xs-generated
                          # code.
                          ' -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable'
                         ),
              LIBS => ['-lstdc++ '.ExtUtils::PkgConfig->libs('opencv')],
              VERSION => '0.001',
              XSOPT => '-hiertype',
              TYPEMAPS => ['typemap.dynamic'],
              BUILD_REQUIRES => {
                                 'ExtUtils::MakeMaker' => 0,
                                 'ExtUtils::Depends' => '0.304',
                                 'ExtUtils::PkgConfig' => 0,
                                 'ExtUtils::ParseXS' => '3.11',
                                },
             );

my $include_directory = ExtUtils::PkgConfig->cflags_only_I('opencv');
$include_directory =~ s/-I//;
$include_directory =~ s/^ +//;
$include_directory =~ s/ +$//;
symlink("$include_directory/cv.h", "opencv_cv.h") or die "Can't make symlink to $include_directory/cv.h: $!";

{
  package MY;

  sub xs_c {
    my $inherited = shift->SUPER::xs_c(@_);

return <<'END';
# FIXME: Why doesn't the TYPEMAPS => [...] entry in the args to EUMM work?

%.c: %.xs typemap.dynamic
	$(XSUBPPRUN) $(XSPROTOARG) $(XSUBPPARGS) -typemap typemap.dynamic $(XSUBPP_EXTRA_ARGS) $*.xs > $*.xsc
	#
	cc -E -c $(PASTHRU_INC) $(INC) \
	$(CCFLAGS) $(OPTIMIZE) \
	$(PERLTYPE) $(MPOLLUTE) $(DEFINE_VERSION) \
	$(XS_DEFINE_VERSION) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) -x c++ $*.xsc > $*.xsi
	#
	$(NOECHO) $(PERLRUN) -p -e 's/opencv_cv::/cv::/g; s/\bopencv_cv\b/cv/g;' $*.xsi > $*.c

END
  }
}

__END__

use ExtUtils::MakeMaker;
use ExtUtils::Depends;
use ExtUtils::PkgConfig;
use Data::Dump::Streamer;

my %pkg_info = ExtUtils::PkgConfig->find('opencv');
my $depends = ExtUtils::Depends->new('OpenCV');
$depends->set_inc($pkg_info{cflags});
$depends->set_libs($pkg_info{libs});
$depends->add_xs('OpenCV.xs');
$depends->add_typemaps('typemap');
$depends->add_pm('lib/OpenCV.pm' => '$(INST_LIBDIR)/OpenCV.pm');
$depends->save_config('lib/OpenCV/Install/Files.pm');

my %args = (
            NAME => 'OpenCV',
            VERSION_FROM => 'lib/OpenCV.pm',

            BUILD_REQUIRES => {
                               'ExtUtils::MakeMaker' => 0,
                               'ExtUtils::Depends' => '0.304',
                               'ExtUtils::PkgConfig' => 0,
                              },

            XSPROTOARG => '-noprototypes',
            XSOPT => '-hiertype',

            CC => 'g++',
            CCFLAGS => '-Wall -Wextra -Wno-unused-parameter -Wno-unused-variable',

            # Unused variables and parameters are both normal in xs-generated code.
            OPTIMIZE => '-ggdb3',

            $depends->get_makefile_vars,
           );

Dump \%args;


WriteMakefile(%args);
