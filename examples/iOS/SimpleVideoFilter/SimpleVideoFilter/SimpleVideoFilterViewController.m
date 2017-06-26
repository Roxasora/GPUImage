#import "SimpleVideoFilterViewController.h"
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface SimpleVideoFilterViewController ()

@property (nonatomic, strong) GPUImageFilter *mainFilter;

@end


@implementation SimpleVideoFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    GPUImageDarkenBlendFilter *blendFilter = [[GPUImageDarkenBlendFilter alloc] init];
    
    GPUImageKuwaharaFilter *kuwaharaFilter = [[GPUImageKuwaharaFilter alloc] init];
    kuwaharaFilter.radius = 2;
    
    GPUImageSmoothToonFilter *toonFilter = [[GPUImageSmoothToonFilter alloc] init];
    toonFilter.threshold = 0.13;
    toonFilter.blurRadiusInPixels = 1.5;
    toonFilter.texelHeight = 1.0 / 1500;
    toonFilter.texelWidth = 1.0 / 1500;
    
    [kuwaharaFilter addTarget:blendFilter];
    [toonFilter addTarget:blendFilter atTextureLocation:1];
    
    [videoCamera addTarget:kuwaharaFilter];
    [videoCamera addTarget:toonFilter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    
    self.mainFilter = blendFilter;
    
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    saturationFilter.saturation = 1.6;
    [self.mainFilter addTarget:saturationFilter];
    
    [saturationFilter addTarget:filterView];
    [videoCamera startCameraCapture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;

        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeRight;
            break;

        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;

        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;

        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    videoCamera.outputImageOrientation = orient;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; // Support all orientations.
}

- (IBAction)updateSliderValue:(id)sender
{
    [(GPUImageCannyEdgeDetectionFilter *)self.mainFilter setLowerThreshold:([(UISlider *)sender value]) * 1.0];
    
}

@end
