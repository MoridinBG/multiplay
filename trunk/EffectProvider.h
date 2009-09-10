//
//  MultitouchScene.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/16/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TuioListener.h"
#import "TuioMultiplexor.h"
#import "TouchEvent.h"
#import "consts.h"
#import "Logger.h"

#import "btPhysics.h"
#import "b2Physics.h"
#import "SparklesPhysics.h"

#import "TargettingInteractor.h"

@class Sparkles;
@class Ripples;
@class SineConnect;
@class LineConnect;
@interface EffectProvider : NSObject 
{
	NSMutableArray *listeners;
	NSThread *physicsThread;
	
	TuioMultiplexor *multiplexor;
	
	NSMutableDictionary *colors;
	NSMutableDictionary *touches;
	
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
