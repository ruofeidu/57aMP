/*****************************************************************************
 *   ViewController.h
 ******************************************************************************
 *   by Kirill Kornyakov and Alexander Shishkov, 13th May 2013
 ******************************************************************************
 *   Chapter 8 of the "OpenCV for iOS" book
 *
 *   Taking Photos From Camera shows how to capture static images
 *   with camera.
 *
 *   Copyright Packt Publishing 2013.
 *   http://bit.ly/OpenCV_for_iOS_book
 *****************************************************************************/

#import <UIKit/UIKit.h>
#import <opencv2/highgui/ios.h>
#import "RetroFilter.hpp"
#import "AFNetworking.h"

@interface ViewController : UIViewController<CvPhotoCameraDelegate>
{
    CvPhotoCamera* photoCamera;
    UIImageView* resultView;
    RetroFilter::Parameters params;
    IBOutlet UIImageView *m_imageView;
    
    UIImage* prevFace;
    NSString* prevWord;
    NSString* currentWord;
    
    int m_dataTimer; 
}

@property (nonatomic, strong) CvPhotoCamera* photoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, weak) IBOutlet
    UIBarButtonItem* takePhotoButton;
@property (nonatomic, weak) IBOutlet
    UIBarButtonItem* startCaptureButton;

-(IBAction)takePhotoButtonPressed:(id)sender;
-(IBAction)startCaptureButtonPressed:(id)sender;

- (UIImage*)applyEffect:(UIImage*)image;

@end
