/*****************************************************************************
 *   ViewController.h
 ******************************************************************************
 *   by Kirill Kornyakov and Alexander Shishkov, 13th May 2013
 ******************************************************************************
 *   Chapter 12 of the "OpenCV for iOS" book
 *
 *   Applying Effects to Live Video shows how to process captured
 *   video frames on the fly.
 *
 *   Copyright Packt Publishing 2013.
 *   http://bit.ly/OpenCV_for_iOS_book
 *****************************************************************************/


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import <opencv2/highgui/ios.h>

@interface ViewController : UIViewController<AVSpeechSynthesizerDelegate, CvVideoCameraDelegate>
{
    CvVideoCamera* videoCamera;
    BOOL isCapturing;
    uint64_t prevTime;
    UIImage* dataImage;
    cv::Mat dataImage_c;
    
    IBOutlet UISwitch *swcCamera;
    IBOutlet UISlider *sldImage;
    IBOutlet UIButton *btnCamera;
    
    
    bool m_readFromFile;
    bool m_readInited;
    NSString* m_prevWord;
    double m_threshold;
    int m_httpTimer;
    
    
    cv::Mat inputFrame, blurFrame, combine, combine1, combine2, inverted;
}

@property (nonatomic, retain) AVSpeechSynthesizer *speechSynthesizer;

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIImageView* maskView;
@property (nonatomic, strong) IBOutlet UIImageView* refView;
@property (nonatomic, strong) IBOutlet UIImageView* ansView;

@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, weak) IBOutlet
    UIBarButtonItem* startCaptureButton;
@property (nonatomic, weak) IBOutlet
    UIBarButtonItem* stopCaptureButton;

-(IBAction)startCaptureButtonPressed:(id)sender;
-(IBAction)stopCaptureButtonPressed:(id)sender;

@end
