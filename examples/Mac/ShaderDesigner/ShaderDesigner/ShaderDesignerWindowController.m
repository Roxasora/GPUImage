#import "ShaderDesignerWindowController.h"
#import "GPUImageTestFilter.h"

NSString *const kGPUImageInitialVertexShaderString = @"attribute vec4 position;\nattribute vec4 inputTextureCoordinate;\n\nvarying vec2 textureCoordinate;\n\n\nvoid main()\n{\n\tgl_Position = position;\n\ttextureCoordinate = inputTextureCoordinate.xy;\n}\n";

NSString *const kGPUImageInitialFragmentShaderString = @"varying vec2 textureCoordinate;\n\nuniform sampler2D inputImageTexture;\nuniform sampler2D inputImageTexture2;\nuniform sampler2D inputImageTexture3;\nuniform float time;\nuniform float randomValue;\nvoid main()\n{\n\tvec4 originalColor = texture2D(inputImageTexture, textureCoordinate);\n\tgl_FragColor = originalColor;\n\tvec2 fragCoord = textureCoordinate;\n\t}\n";


@interface ShaderDesignerWindowController ()

@property (nonatomic, strong) GPUImagePicture *lookupTableImage;
@property (nonatomic, strong) GPUImagePicture *shineImage;

@end

@implementation ShaderDesignerWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    inputCamera = [[GPUImageAVCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraDevice:nil];
//    inputCamera.runBenchmark = YES;

    self.vertexShader = kGPUImageInitialVertexShaderString;
    self.fragmentShader = kGPUImageInitialFragmentShaderString;
    
    [inputCamera addTarget:self.previewView];
    self.previewView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    [inputCamera startCameraCapture];
    
    self.shineImage = [[GPUImagePicture alloc] initWithImage:[NSImage imageNamed:@"bokeh_texture2"]];
    self.lookupTableImage = [[GPUImagePicture alloc] initWithImage:[NSImage imageNamed:@"shine"]];

    [self compile:self];
}

- (IBAction)compile:(id)sender;
{
    [self.window makeFirstResponder:nil];
    // Test compilation first, see if it will work
    __block BOOL compilationFailed = NO;
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        GLProgram *filterProgram = [[GLProgram alloc] initWithVertexShaderString:self.vertexShader fragmentShaderString:self.fragmentShader];
        
        if (!filterProgram.initialized)
        {
            if (![filterProgram link])
            {
                compilationFailed = YES;
                [self.displayTabView selectTabViewItem:self.logTabItem];
                self.compileLog = [NSString stringWithFormat:@"Vertex shader log:\n%@\n\nFragment shader log:\n%@\n\nProgram log:\n%@\n\n", [filterProgram programLog], [filterProgram fragmentShaderLog], [filterProgram vertexShaderLog]];
            }
        }
    });
    if (compilationFailed)
    {
        return;
    }

    [self.displayTabView selectTabViewItem:self.displayTabItem];
    
    [inputCamera pauseCameraCapture];
    if (testFilter != nil)
    {
        [inputCamera removeTarget:testFilter];
        [testFilter removeTarget:self.shaderOutputView];
    }
    testFilter = [[GPUImageTestFilter alloc] initWithVertexShaderFromString:self.vertexShader fragmentShaderFromString:self.fragmentShader];
    
    [inputCamera addTarget:testFilter];
    
    [self.shineImage removeAllTargets];
    [self.shineImage processImage];
    [self.shineImage addTarget:testFilter atTextureLocation:1];
    
    [self.lookupTableImage removeAllTargets];
    [self.lookupTableImage processImage];
    [self.lookupTableImage addTarget:testFilter atTextureLocation:2];
    
    [testFilter addTarget:self.shaderOutputView];
    
    [inputCamera resumeCameraCapture];
}

#pragma mark -
#pragma mark File loading / saving

- (IBAction)openVertexShader:(id)sender;
{
    NSOpenPanel *shaderLoadingDialog = [NSOpenPanel openPanel];
    [shaderLoadingDialog setAllowedFileTypes:[NSArray arrayWithObjects:@"vsh", @"txt", nil]];
    
    if ( [shaderLoadingDialog runModal] == NSModalResponseOK )
    {
        NSError *error = nil;
        NSString *fileContents = [NSString stringWithContentsOfURL:[shaderLoadingDialog URL] encoding:NSASCIIStringEncoding error:&error];
        if (fileContents == nil)
        {
            if (error == nil)
            {
                NSLog(@"Don't have an error to present for failing to save topography map");
            }
            
            [NSApp presentError:error];
        }
        else
        {
            self.vertexShader = fileContents;
        }
    }
}

- (IBAction)openFragmentShader:(id)sender;
{
    NSOpenPanel *shaderLoadingDialog = [NSOpenPanel openPanel];
    [shaderLoadingDialog setAllowedFileTypes:[NSArray arrayWithObjects:@"fsh", @"txt", nil]];
    
    if ( [shaderLoadingDialog runModal] == NSModalResponseOK )
    {
        NSError *error = nil;
        NSString *fileContents = [NSString stringWithContentsOfURL:[shaderLoadingDialog URL] encoding:NSASCIIStringEncoding error:&error];
        if (fileContents == nil)
        {
            if (error == nil)
            {
                NSLog(@"Don't have an error to present for failing to save topography map");
            }
            
            [NSApp presentError:error];
        }
        else
        {
            self.fragmentShader = fileContents;
        }
    }
}

- (IBAction)saveVertexShader:(id)sender;
{
    NSSavePanel *shaderSavingDialog = [NSSavePanel savePanel];
    [shaderSavingDialog setAllowedFileTypes:[NSArray arrayWithObjects:@"vsh", @"txt", nil]];
    
    if ( [shaderSavingDialog runModal] == NSModalResponseOK )
    {
        NSError *error = nil;
        if (![self.vertexShader writeToURL:[shaderSavingDialog URL] atomically:NO encoding:NSASCIIStringEncoding error:&error])
        {
            if (error == nil)
            {
                NSLog(@"Don't have an error to present for failing to save topography map");
            }
            
            [NSApp presentError:error];
        }
    }
}

- (IBAction)saveFragmentShader:(id)sender;
{
    NSSavePanel *shaderSavingDialog = [NSSavePanel savePanel];
    [shaderSavingDialog setAllowedFileTypes:[NSArray arrayWithObjects:@"fsh", @"txt", nil]];
    
    if ( [shaderSavingDialog runModal] == NSModalResponseOK )
    {
        NSError *error = nil;
        if (![self.fragmentShader writeToURL:[shaderSavingDialog URL] atomically:NO encoding:NSASCIIStringEncoding error:&error])
        {
            if (error == nil)
            {
                NSLog(@"Don't have an error to present for failing to save topography map");
            }
            
            [NSApp presentError:error];
        }
    }
}

@end
