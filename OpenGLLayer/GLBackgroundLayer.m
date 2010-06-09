//
//  GLBackgroundLayer.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 3/29/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "GLBackgroundLayer.h"


@implementation GLBackgroundLayer
- (id)init 
{
	self = [super init];
	self.asynchronous = YES;
	return self;
}

- (void)drawInCGLContext:(CGLContextObj)glContext 
             pixelFormat:(CGLPixelFormatObj)pixelFormat 
            forLayerTime:(CFTimeInterval)interval 
             displayTime:(const CVTimeStamp *)timeStamp 
{	
	glClearColor(BACKGROUND, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	glFlush();
}

- (void)releaseCGLPixelFormat:(CGLPixelFormatObj)pixelFormat 
{
	CGLDestroyPixelFormat(pixelFormat);
}

- (CGLPixelFormatObj)copyCGLPixelFormatForDisplayMask:(uint32_t)mask 
{
	CGLPixelFormatAttribute attribs[] =
	{
		kCGLPFAAccelerated,
		kCGLPFADoubleBuffer,
		kCGLPFAColorSize, 24,
		kCGLPFADepthSize, 16,
		0
	};
	
	CGLPixelFormatObj pixelFormatObj = NULL;
	GLint numPixelFormats = 0;
	
	CGLChoosePixelFormat(attribs, &pixelFormatObj, &numPixelFormats);
	return pixelFormatObj;
}

@end
