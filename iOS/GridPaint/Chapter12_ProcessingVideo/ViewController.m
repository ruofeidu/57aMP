/*****************************************************************************
 *   ViewController.m
 ******************************************************************************
 *   Thermal Grid
 *
 *   Ruofei Du
 *   Tiffany Chao
 *****************************************************************************/

#import "ViewController.h"
#import <mach/mach_time.h> 
#import "AFNetworking.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()

@end

@implementation ViewController

@synthesize imageView;
@synthesize refView;
@synthesize maskView;
@synthesize ansView;
@synthesize startCaptureButton;
@synthesize toolbar;
@synthesize videoCamera;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize camera
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;  // AVCaptureDevicePositionBack;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    // Hide status bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {         // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {                                                                              // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

    //AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = 30;
    
    isCapturing = NO;
    prevTime = mach_absolute_time();
    imageView.image = [UIImage imageNamed:@"bg.jpg"];
    
    //read from file
    dataImage = [UIImage imageNamed:@"11.png"];
    UIImageToMat(dataImage, dataImage_c);
    m_readFromFile = false;
    m_readInited = false;
    
    //Instantiate the object that will allow us to use text to speech
    self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    [self.speechSynthesizer setDelegate:self];
    
    // Init everything
    m_prevWord = @"";
    
    m_threshold = 127;
    m_httpTimer = 0;
}

- (NSUInteger)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)swcCameraChanged:(id)sender {
    if (swcCamera.isOn || !isCapturing) {
        [videoCamera start];
        isCapturing = YES;
        
    } else {
        [videoCamera stop];
        isCapturing = NO;
    }
}

//TODO: remove this code
static double machTimeToSecs(uint64_t time)
{
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer / (double)timebase.denom / 1e9;
}

// Macros for time measurements
#if 1
  #define TS(name) int64 t_##name = cv::getTickCount()
  #define TE(name) printf("TIMER_" #name ": %.2fms\n", \
    1000.*((cv::getTickCount() - t_##name) / cv::getTickFrequency()))
#else
  #define TS(name)
  #define TE(name)
#endif

- (IBAction)takePhoto:(id)sender {
    UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil);
}

- (void)processImage:(cv::Mat&)image
{
    
    int n = image.rows;
    int m = image.cols;
    int blurKernel = 25;
    
    n = 350; m = 250;
    
    cv::resize(image, inputFrame, cv::Size(n, m));
    
    cv::cvtColor(inputFrame, inputFrame, CV_RGBA2BGR);
    cv::blur( inputFrame, blurFrame, cv::Size(blurKernel, blurKernel));
    
    cv::hconcat(inputFrame, blurFrame, combine1);
    
    blurFrame.copyTo(inputFrame);
    
    cv::cvtColor(inputFrame, inputFrame, CV_BGR2GRAY);
    cv::threshold(inputFrame, inputFrame, m_threshold, 255, CV_THRESH_BINARY);
    
    int gridN = 5;
    int gridM = 7;
    int pieceN = inputFrame.rows / gridN;
    int pieceM = inputFrame.cols / gridM;
    
    int threshold = 127, BLACK = 255, WHITE = 0, paintcolor = 0;
    float ratio = 0.5;
    
    
    unsigned char *input = (unsigned char*)(inputFrame.data);
    NSString* str = @"";
    
    for (int i = 0; i < gridN; ++i) {
        for (int j = 0; j < gridM; ++j) {
            int total = 0; int black = 0;
            for (int k = pieceN * i; k < pieceN * (i+1); ++k) {
                for (int b = pieceM * j; b < pieceM * (j+1); ++b) {
                    if (k >= inputFrame.rows || b >= inputFrame.cols) continue;
                    ++total;
                    if (input[k * inputFrame.step + b] > m_threshold) ++black;
                }
            }
            
            if (black > total * ratio) {
                paintcolor = BLACK;
                str = [str stringByAppendingString:@"1"];
            } else {
                paintcolor = WHITE;
                str = [str stringByAppendingString:@"0"];
            }
            
            for (int k = pieceN * i; k < pieceN * (i+1); ++k) {
                for (int b = pieceM * j; b < pieceM * (j+1); ++b) {
                    if (k >= inputFrame.rows || b >= inputFrame.cols) continue;
                    input[k * inputFrame.step + b] = paintcolor;
                }
            }
        }
    }
    
    
    if (++m_httpTimer > 40) {
        m_httpTimer = 0;
        if (![str isEqualToString:m_prevWord]) {
            NSLog(@"Http Request: %@", str);
            [self sendMessage:str];
            m_prevWord = [NSString stringWithFormat:@"%@", str];;
        }
    }
    
    inputFrame.copyTo(inverted);
    unsigned char* invertPixels = (unsigned char*)(inverted.data);
    
    for (int i = 0; i < inverted.rows; ++i) {
        for (int j = 0; j < inverted.cols; ++j) {
            invertPixels[i * inverted.step + j] = 255 - invertPixels[i * inverted.step + j];
        }
    }
    
    cv::cvtColor(inputFrame, inputFrame, CV_GRAY2BGR);
    cv::cvtColor(inverted, inverted, CV_GRAY2BGR);
    
    cv::hconcat(inputFrame, inverted, combine2);
    cv::vconcat(combine1, combine2, combine);
    cv::vconcat(combine1, combine2, combine);
    
    cv::resize(combine, combine, image.size());
    
    
    if (!combine.empty()) combine.copyTo(image);
    
    combine.release();
    
    combine1.release();
    combine2.release();
    inverted.release();
    inputFrame.release();
    blurFrame.release();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [videoCamera stop];
    [videoCamera start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (isCapturing)
    {
        [videoCamera stop];
        [videoCamera start];
    }
}

-(void) sendMessage: (NSString*) message
{
    NSString* BaseURLString = @"http://duruofei.com/ThermalGrid/";
    
    NSString *string = [NSString stringWithFormat:@"%@?add=%@", BaseURLString, message];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Anyway we send the data");
    }];
    
    [operation start];
}

- (void)dealloc
{
    videoCamera.delegate = nil;
}

- (IBAction)btnCameraTouched:(id)sender {
    sldImage.value = ((int)sldImage.value + 1) % 10;
    //sldImageSwitched(sender);
    [self RefreshImage];
}

- (IBAction)sldImageSwitched:(id)sender {
    m_threshold = (int)sldImage.value; 
}

- (void) RefreshImage {
    if (sldImage.value > 10) {
        dataImage = [UIImage imageNamed: [NSString stringWithFormat:@"%d.png", (int)sldImage.value] ];
    } else {
        dataImage = [UIImage imageNamed: [NSString stringWithFormat:@"%d.jpg", (int)sldImage.value] ];
    }
    UIImageToMat(dataImage, dataImage_c);
    
    [self speakText:[NSString stringWithFormat:@"%d", (int)sldImage.value]];
}

- (void)speakText:(NSString *)toBeSpoken{
    if ([toBeSpoken isEqualToString:m_prevWord]) return;
    if ([self.speechSynthesizer isSpeaking]) [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    m_prevWord = toBeSpoken;
    AVSpeechUtterance *utt = [AVSpeechUtterance speechUtteranceWithString:toBeSpoken];
    utt.rate = 0.8;
    [self.speechSynthesizer speakUtterance:utt];
}


@end
