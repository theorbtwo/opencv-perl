extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#undef NORMAL

#define cv opencv_cv
#include <cv.h>
#undef cv

void *_ZN9opencv_cv17CascadeClassifierC1Ev;
extern void *_ZN2cv17CascadeClassifierC1Ev;

MODULE = OpenCV   PACKAGE = OpenCV

BOOT:
 _ZN9opencv_cv17CascadeClassifierC1Ev = _ZN2cv17CascadeClassifierC1Ev;


MODULE = OpenCV::CascadeClassifier  PACKAGE = OpenCV::CascadeClassifier

opencv_cv::CascadeClassifier *
opencv_cv::CascadeClassifier::new()

MODULE = OpenCV   PACKAGE = OpenCV

