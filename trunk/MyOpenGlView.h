//
//  MyOpenGlView.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/15/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>

#import "Sparkles.h"
#import "Ripples.h"
#import "SineConnect.h"
#import "LineConnect.h"
#import "TextCircle.h"

@class NSOpenGLContext, NSOpenGLPixelFormat;

@interface MyOpenGLView : NSView 
{
@private 
	NSOpenGLContext *_fullscreenContext; 
	NSOpenGLContext *_windowContext;
	
	bool fullscreen;
	EffectProvider <EffectProviderProtocol> *provider;
	NSRect projectionSize;
} 

- (id)initWithFrame:(NSRect)frameRect;
- (void) fullscreen:(id)sender;
- (NSSize) dimensions;
- (NSOpenGLContext*)openGLContext;

@end