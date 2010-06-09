//
//  Steps.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/29/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//
#define STEP_WIDTH 0.1f
#define MAX_STEPS 35.f

#import <Cocoa/Cocoa.h>

#import "GLContentLayer.h"
#import "GlobalFunctions.h"

@interface Steps : GLContentLayer
{
	GLuint leftFootTexture;
	GLuint rightFootTexture;
	
	int frame;
}

- (id) init;
- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat;
- (void) drawGL;

@end
