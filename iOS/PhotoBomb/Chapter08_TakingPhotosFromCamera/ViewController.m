/*****************************************************************************
 *   PhotoBomb.m
 *****************************************************************************/

#import "ViewController.h"
#import "opencv2/highgui/ios.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize imageView;
@synthesize toolbar;
@synthesize photoCamera;
@synthesize takePhotoButton;
@synthesize startCaptureButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize camera
    photoCamera = [[CvPhotoCamera alloc]
                        initWithParentView:imageView];
    photoCamera.delegate = self;
    photoCamera.defaultAVCaptureDevicePosition =
                        AVCaptureDevicePositionFront;
    photoCamera.defaultAVCaptureSessionPreset =
                        AVCaptureSessionPresetPhoto;
    photoCamera.defaultAVCaptureVideoOrientation =
                        AVCaptureVideoOrientationPortrait;
    
    // Load images
    UIImage* resImage = [UIImage imageNamed:@"scratches.png"];
    UIImageToMat(resImage, params.scratches);
    
    resImage = [UIImage imageNamed:@"fuzzy_border.png"];
    UIImageToMat(resImage, params.fuzzyBorder);
    
    [takePhotoButton setEnabled:NO];
    prevFace = [UIImage imageNamed:@"lisa.png"];
    
    m_imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [m_imageView addGestureRecognizer:tap];
    
    [m_imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [photoCamera start];
    [self.view addSubview:imageView];
    [takePhotoButton setEnabled:YES];
    [startCaptureButton setEnabled:NO];
    
    m_dataTimer = 0;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(getData:)
                                   userInfo:nil
                                    repeats:YES];
}


- (NSInteger)supportedInterfaceOrientations
{
    // Only portrait orientation supported
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)takePhotoButtonPressed:(id)sender;
{
    [photoCamera takePicture];
}

-(IBAction)startCaptureButtonPressed:(id)sender;
{
    [photoCamera start];
    [self.view addSubview:imageView];
    [takePhotoButton setEnabled:YES];
    [startCaptureButton setEnabled:NO];
}

- (void)imageTapped:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Image Taped");
    [photoCamera takePicture];
}

- (UIImage*)applyEffect:(UIImage*)image;
{
    cv::Mat frame;
    UIImageToMat(image, frame);
    
    params.frameSize = frame.size();
    RetroFilter retroFilter(params);
    
    cv::Mat finalFrame;
    retroFilter.applyToPhoto(frame, finalFrame);
    
    UIImage* result = MatToUIImage(finalFrame);
    return [UIImage imageWithCGImage:[result CGImage]
                               scale:1.0
                         orientation:UIImageOrientationLeftMirrored];
}

- (void)photoCamera:(CvPhotoCamera*)camera
                    capturedImage:(UIImage *)image;
{
    //[camera stop];
    resultView = [[UIImageView alloc]
                  initWithFrame:imageView.bounds];
    
    UIImage* result = [self applyEffect:image];
   
    [resultView setImage:prevFace];
    
    prevFace = result;
    
    [self.view addSubview:resultView];
    
    //[takePhotoButton setEnabled:NO];
    //[startCaptureButton setEnabled:YES];
}

- (void)getData :(NSTimer *)timer {
    NSString* BaseURLString = @"http://duruofei.com/ThermalGrid/";
    
    NSString *string = [NSString stringWithFormat:@"%@?last=1", BaseURLString];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        currentWord = operation.responseString;
        if (![currentWord isEqualToString: prevWord]) {
            prevWord = [NSString stringWithFormat:@"%@", currentWord];
            [photoCamera takePicture];
        }
        NSLog(@"%@", operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Anyway we send the data");
    }];
    
    [operation start];
}

- (void)photoCameraCancel:(CvPhotoCamera*)camera;
{
}

- (void)viewDidDisappear:(BOOL)animated
{
    [photoCamera stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    photoCamera.delegate = nil;
}
@end
