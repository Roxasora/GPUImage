//
//  GPUImageTestFilter.h
//  ShaderDesigner
//
//  Created by bigcatlee on 2017/12/26.
//  Copyright © 2017年 Sunset Lake Software. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface GPUImageTestFilter : GPUImageThreeInputFilter {
    GLint timeUniform;
    GLint randomValueUniform;
    GLint progressUniform;
}

@property(readwrite, nonatomic) CGFloat time;

@property(readwrite, nonatomic) CGFloat progress;

@property(readwrite, nonatomic) CGFloat randomValue;

@end
