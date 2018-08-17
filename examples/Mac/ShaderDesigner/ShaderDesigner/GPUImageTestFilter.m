//
//  GPUImageTestFilter.m
//  ShaderDesigner
//
//  Created by bigcatlee on 2017/12/26.
//  Copyright © 2017年 Sunset Lake Software. All rights reserved.
//

#import "GPUImageTestFilter.h"

@implementation GPUImageTestFilter

- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString {
    self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString];
    
    timeUniform = [filterProgram uniformIndex:@"time"];
    self.time = 0.0;
    
    progressUniform = [filterProgram uniformIndex:@"progress"];
    self.progress = 0.0;
    
    randomValueUniform = [filterProgram uniformIndex:@"randomValue"];
    self.randomValue = 0.0;
    
    return self;
}


- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime {
    float currentTime = CMTimeGetSeconds(frameTime);
    self.time = fmod(currentTime, 600);
    self.progress = MIN(1.0, fmod(currentTime, 4.0) / 2.0);
    NSLog(@"%lf", self.progress);
    
    float mixProgress = pow(cos((self.progress-0.5)*6.0), 1.5);
    NSLog(@"%lf", mixProgress);
    
    
    self.randomValue = (float)(arc4random() % 1000) / 1000.0;
    
    [super informTargetsAboutNewFrameAtTime:frameTime];
}

- (void)setTime:(CGFloat)time {
    _time = time;
    [self setFloat:time forUniform:timeUniform program:filterProgram];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setFloat:progress forUniform:progressUniform program:filterProgram];
}

- (void)setRandomValue:(CGFloat)randomValue {
    _randomValue = randomValue;
    [self setFloat:randomValue forUniform:randomValueUniform program:filterProgram];
}


@end
