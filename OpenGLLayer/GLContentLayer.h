//
//  OpenGLLayer.h
//  OpenGLLayer
//
//  Created by Bill Dudney on 11/30/07.
//  Copyright 2007 Gala Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>

#import <TUIO/TuioClient.h>
#import <TUIO/TuioBounds.h>

#import "RGBA.h"
#import "InteractiveObject.h"
#import "consts.h"
#import "Logger.h"
#import "GlobalFunctions.h"

@interface GLContentLayer : CAOpenGLLayer <TuioBoundsListener>
{
	NSMutableDictionary *objects;
	NSMutableDictionary *objectColors;
	GLUtesselator *tess;
	
	GLbitfield clearBitfield;
	
	float _aspect;
}
@property(assign) BOOL animate;
@property(assign) TuioBounds *tuioBounds;

- (void) setBounds:(CGRect)bounds;

- (void) drawGL;
- (CGPoint) getRandomPointWithinDimension;

- (void) tuioBoundsAdded: (TuioBounds*) newBounds;
- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds;
- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds;
- (void) tuioFrameFinished;

@end
