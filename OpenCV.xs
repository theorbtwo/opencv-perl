extern "C" {
#define cv perl_cv

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#undef NORMAL
#undef cv
}

#include "opencv_cv.h"
#include <highgui.h>
#undef cv

#define cv perl_cv

MODULE = OpenCV   PACKAGE = OpenCV

PROTOTYPES: DISABLE

opencv_cv::Mat*
imread(char *filename)
 CODE:
  const opencv_cv::string filename_string = filename;
  /* My kingdom for a decent explination of C++ and coping... */
  /* CV_EXPORTS Mat imread( const string& filename, int flags=1 ); */
  opencv_cv::Mat *pmat = new opencv_cv::Mat;
  opencv_cv::Mat mat;
  mat = opencv_cv::imread(filename_string);
  *pmat = mat;
  RETVAL = pmat;
 OUTPUT:
  RETVAL

MODULE = OpenCV::Mat PACKAGE = OpenCV::Mat

int
opencv_cv::Mat::channels()

bool
opencv_cv::Mat::isContinuous()

bool
opencv_cv::Mat::elemSize()

bool
opencv_cv::Mat::elemSize1()


opencv_cv::Mat*
cvtColor(opencv_cv::Mat *src, int code, int dstCn=0)
 CODE:
  /* CV_EXPORTS void cvtColor( const Mat& src, Mat& dst, int code, int dstCn=0 ); */
  RETVAL = new opencv_cv::Mat;
  opencv_cv::cvtColor(*src, *RETVAL, code, dstCn);
 OUTPUT:
  RETVAL

opencv_cv::Mat*
equalizeHist(opencv_cv::Mat *src)
 CODE:
  /* CV_EXPORTS void equalizeHist( const Mat& src, Mat& dst ); */
  RETVAL = new opencv_cv::Mat;
  opencv_cv::equalizeHist(*src, *RETVAL);
 OUTPUT:
  RETVAL

MODULE = OpenCV::CascadeClassifier  PACKAGE = OpenCV::CascadeClassifier

opencv_cv::CascadeClassifier*
opencv_cv::CascadeClassifier::new()

bool
opencv_cv::CascadeClassifier::load(char *filename)
 CODE:
  /* cv.hpp, line 681 */
  /* bool load(const string& filename); */
  const opencv_cv::string filename_string = filename;
  RETVAL = THIS->load(filename);
 OUTPUT:
  RETVAL

std::vector<opencv_cv::Rect>*
opencv_cv::CascadeClassifier::detectMultiScale(opencv_cv::Mat* image, double scaleFactor=1.1, int minNeighbors=3, int flags=0, opencv_cv::Size* minSize)
 CODE:
  /* void detectMultiScale( const Mat& image,
                           vector<Rect>& objects,
                           double scaleFactor=1.1,
                           int minNeighbors=3, int flags=0,
                           Size minSize=Size());
  */
  std::vector<opencv_cv::Rect> *objects = new std::vector<opencv_cv::Rect>();
  THIS->detectMultiScale((const opencv_cv::Mat&)*image, *objects, scaleFactor, minNeighbors, flags, *minSize);
  RETVAL = objects;
 OUTPUT:
  RETVAL

MODULE = OpenCV::Size   PACKAGE = OpenCV::Size

opencv_cv::Size*
opencv_cv::Size::new(int x, int y)

MODULE = OpenCV::Vector::Rect PACKAGE = OpenCV::Vector::Rect

IV
size(std::vector<opencv_cv::Rect>* THIS)
 CODE:
  RETVAL = THIS->size();
 OUTPUT:
  RETVAL
 
opencv_cv::Rect*
at(std::vector<opencv_cv::Rect>* THIS, IV i)
 CODE:
  RETVAL = new opencv_cv::Rect(THIS->at(i));
 OUTPUT:
  RETVAL


MODULE = OpenCV::Rect PACKAGE = OpenCV::Rect

# Rect is Rect_<int>

int
x(opencv_cv::Rect* THIS)
 CODE:
  RETVAL = THIS->x;
 OUTPUT:
  RETVAL

int
y(opencv_cv::Rect* THIS)
 CODE:
  RETVAL = THIS->y;
 OUTPUT:
  RETVAL

int
width(opencv_cv::Rect* THIS)
 CODE:
  RETVAL = THIS->width;
 OUTPUT:
  RETVAL

int
height(opencv_cv::Rect* THIS)
 CODE:
  RETVAL = THIS->height;
 OUTPUT:
  RETVAL


MODULE = OpenCV   PACKAGE = OpenCV

