#!/bin/env perl
use warnings;
use strict;
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

            CCFLAGS => '-x c++',

            OPTIMIZE => '-ggdb3 -feliminate-dwarf2-dups',

            $depends->get_makefile_vars
           );

Dump \%args;

WriteMakefile(%args);
