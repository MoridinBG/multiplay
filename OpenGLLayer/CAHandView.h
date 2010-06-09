//
//  MyView.h
//  OpenGLLayer
//
//  Created by Bill Dudney on 02/21/08.
//  Copyright 2008 Gala Factory. All rights reserved.
//

#define ROTATE_INTERVAL 30

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>
#import <TUIO/TuioClient.h>

#import "GlobalFunctions.h"

#import "GLContentLayer.h"
#import "GLBackgroundLayer.h"

#import "BoundariesBurn.h"
#import "Painter.h"
#import "Stripes.h"
#import "RGBTrailes.h"
#import "Superfluid.h"
#import "Balls.h"
#import "PictureMagnet.h"
#import "Connector.h"
#import "Steps.h"

@interface CAHandView : NSView
{
	TuioClient *_tuioClient;
	NSTimer *rotationTimer;
	
	NSMutableArray *allEffects;
	NSMutableArray *currentEffects;
	CALayer *currentContentLayer;
	GLBackgroundLayer *bgLayer;
}

- (void) rotateLayers:(NSTimer*) theTimer;

@end
