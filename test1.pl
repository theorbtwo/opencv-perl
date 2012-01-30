#!/usr/bin/perl
$|=1;
use strictures 1;
use autodie;
use 5.10.0;

use OpenCV;

my $face_cascade = OpenCV::CascadeClassifier->new();
say "The cascadeclassifier: ", $face_cascade;

my $ret = $face_cascade->load('/usr/src/autotagger/OpenCV/haarcascade_frontalface_alt.xml');
say "Loading the face cascade returned $ret";

my $mat = OpenCV::imread(shift);
say "Got back a mat from imread: $mat";

my $channels = $mat->channels;
say "Channels: $channels";

say "Is continuous: ", $mat->isContinuous;
say "Elem size: ", $mat->elemSize;
say "Elem size (each channel): ", $mat->elemSize1;

# CV_BGR2GRAY -- FIXME: export these, or make available a hash of these?
my $grey_mat = $mat->cvtColor(6);
say "Grey matrix channels: ", $grey_mat->channels;

$grey_mat = $grey_mat->equalizeHist();
# second 2 is CV_HAAR_SCALE_IMAGE
print "Trying to detectMultiScale\n";
my $vec = $face_cascade->detectMultiScale($grey_mat, 1.1, 2, 2, OpenCV::Size->new(30, 30));
print "Done!\n";

say "Number of returned objects: ", $vec->size;

for my $i (0..$vec->size-1) {
  my $rect = $vec->at($i);
  say "Rectangle at index $i: ", $rect;
  say " x: ", $rect->x;
  say " y: ", $rect->y;
  say " width: ", $rect->width;
  say " height: ", $rect->height;

}
