#!/usr/bin/env perl

use Web::Simple 'CheckFaces';

{

    package CheckFaces;

    use blib '/home/castaway/opencv-perl/blib';
    use OpenCV;
    use Imager;
    use Path::Class;

    sub dispatch_request {
        sub (GET + ?image=) {
            my ($self, $image) = @_;
            ## apply opencv.. 
            my $size = $self->find_faces($image);
            my $vars = { tmpimage => "/tmp/" . Path::Class::File->new($image)->basename };
            my $pieces = join('', map { "<img src='file:///tmp/$_.jpg'/>"   } (1..$size));
            $vars->{pieces} = $pieces;

            [200, [ 'Content-Type' => 'text/html'], [ $self->template($vars) ]];
        }
    }

    sub find_faces {
        my ($self, $in_fn) = @_;

        my $face_cascade = OpenCV::CascadeClassifier->new();
        my $ret = $face_cascade->load('/usr/src/autotagger/OpenCV/haarcascade_frontalface_alt.xml');

        my $mat = OpenCV::imread($in_fn);
        my $grey_mat = $mat->cvtColor(6);
        my $vec = $face_cascade->detectMultiScale($grey_mat, 1.1, 2, 2, OpenCV::Size->new(30, 30));

        my $fn_base = Path::Class::File->new($in_fn)->basename;
        if($vec->size) {
            my $imager = Imager->new(file => $in_fn) or die Imager->errstr();

            for my $i (0..$vec->size-1) {
                my $rect = $vec->at($i);
#                say "Rectangle at index $i: ", $rect;
#                say " x: ", $rect->x;
#                say " y: ", $rect->y;
#                say " width: ", $rect->width;
#                say " height: ", $rect->height;

                my $part = $imager->crop(left => $rect->x, top => $rect->y, width => $rect->width, height => $rect->height); 
                $part->write(file => "/tmp/" . ($i+1) . ".jpg") or die $part->errstr;

                $imager->box(color => 'black',
                             xmin => $rect->x,
                             ymin => $rect->y,
                             xmax => $rect->x + $rect->width,
                             ymax => $rect->y + $rect->height) or die $imager->errstr;
                
                $imager->box(color => 'white',
                             xmin => $rect->x-1,
                             ymin => $rect->y-1,
                             xmax => $rect->x + $rect->width+2,
                             ymax => $rect->y + $rect->height+2) or die $imager->errstr;
                
                $imager->box(color => 'black',
                             xmin => $rect->x-2,
                             ymin => $rect->y-2,
                             xmax => $rect->x + $rect->width+4,
                             ymax => $rect->y + $rect->height+4) or die $imager->errstr;
            }
            
            $imager->write(file => "/tmp/$fn_base") or die $imager->errstr;
        }

        return $vec->size;

    }

    sub template {
        my ($self, $vars) = @_;

        ## should probably be TT as then we can loop over pieces instead of doing the silly!
        return << "TEMPLATE";
<html>
<head></head>
<body>
<img src="file://$vars->{tmpimage}"><br>
$vars->{pieces}
</body>
</html>
TEMPLATE
    }

}


CheckFaces->run_if_script;
