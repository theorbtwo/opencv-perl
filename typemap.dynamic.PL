#!/usr/bin/perl
use strictures 1;
use autodie;
use ExtUtils::Typemaps;

my $outfn = shift;

my $typemap = ExtUtils::Typemaps->new();

my $types = [
             {
              cname => "opencv_cv::CascadeClassifier*",
              perlname => "OpenCV::CascadeClassifier",
             },
             {
              cname => "opencv_cv::Mat*",
              perlname => "OpenCV::Mat",
             },
             {
              cname => "opencv_cv::Size*",
              perlname => "OpenCV::Size",
             },
             {
              cname => "opencv_cv::Rect*",
              perlname => "OpenCV::Rect",
             },
             {
              cname => "std::vector<opencv_cv::Rect>*",
              perlname => "OpenCV::Vector::Rect",
             },
            ];

for my $type (@$types) {
  my $definename = $type->{cname};
  $definename =~ s/:/_colon_/g;
  $definename =~ s/\*/_star_/g;
  $definename =~ s/</_lt_/g;
  $definename =~ s/>/_gt_/g;
  $definename = "TYPEMAP_CONST_".$definename;

  print "Working on $definename\n";

  print "Add_typemap\n";
  $typemap->add_typemap(ctype => $type->{cname}, xstype => $definename);

  print "add_inputmap\n";
  # Possibly we should check that \$var isa ...
  $typemap->add_inputmap(xstype => $definename,
                         code => <<"END",
    if( sv_isobject(\$arg) && (SvTYPE(SvRV(\$arg)) == SVt_PVMG) )
      \$var = (\$type)SvIV((SV*)SvRV( \$arg ));
    else {
      warn( \\"\${Package}::\$func_name() -- \$var is not a blessed SV reference\\" );
            XSRETURN_UNDEF;
    }
END
                        );

  print "add_outputmap\n";
  my $perlname = $type->{perlname};
  $typemap->add_outputmap(xstype => $definename,
                         code => <<"END",
    sv_setref_pv( \$arg, "$perlname", (void*)\$var );
END
                        );

}

open my $outfh, ">", $outfn;
print $outfh $typemap->as_string;

