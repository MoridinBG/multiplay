//
//  MultitouchScene.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/16/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TuioListener.h"
#import "TouchEvent.h"
#import "consts.h"
#import "Logger.h"

#import "btPhysics.h"
#import "SparklesPhysics.h"

@class Sparkles;
@class Ripples;
@class SineConnect;
@interface EffectProvider : NSObject 
{
	TuioListener *listener;
	id physicsThread;
	
	NSMutableDictionary *colors;
	
	float *cosArray;
	float *cosOffsetArray;
	
	float *sinArray;
	float *sinOffsetArray;
	
	float *vertexArray;
	
	NSSize dimensions;
	
}
- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) setDimensions:(NSSize) dimensions_;
@end
