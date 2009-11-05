//
//  MultitouchScene.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/16/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TuioMultiplexor.h"
#import "TouchEvent.h"
#import "consts.h"
#import "Logger.h"

#import "btPhysics.h"
#import "b2Physics.h"

#import "TargettingInteractor.h"

#ifdef __cplusplus
#import "TUIOppListener.h"
#endif

@class Sparkles;
@class Stars;
@class SineConnect;
@class LineConnect;
@class TextCircle;
@class Ripples;
@class InteractiveImages;
@class TouchSwap;
@interface EffectProvider : NSObject 
{
	NSMutableArray *listeners;
	b2Physics *physics;
	
	TuioMultiplexor *multiplexor;
	
	NSMutableDictionary *colors;
	NSMutableDictionary *touches;
	NSMutableArray *activeUIDs;
	
	float *cosArray;
	float *cosOffsetArray;
	
	float *sinArray;
	float *sinOffsetArray;
	
	float *vertexArray;
	
	CGSize dimensions;
	
	NSRecursiveLock *lock;
	
	#ifdef __cplusplus
	TUIOppListener *listener;
	TUIOppListener *listener2;
	TUIOppListener *listener3;	
	#endif
}
- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) setDimensions:(CGSize) dimensions_;
@end
