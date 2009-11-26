//
//  TouchSwap.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//
#define MIN_SECONDS_BEFORE_SWAP 3
#define MAX_SECONDS_BEFORE_SWAP 7
#define TRAJECTORY_TRAVERSE_STEPS (FRAMES * 2)

#define BEZIER_MIN_CONTROL_POINT_DISTANCE 1
#define BEZIER_MAX_CONTROL_POINT_DISTANCE 9
#define BEZIER_MIN_CURVING 4
#define BEZIER_MAX_CURVING 20

#define SWAPPING_TOUCH_WIDTH (side / 2)
#define SWAPPING_TOUCH_HEIGHT (side / 2)

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"
#import "InteractiveObject.h"

#import "Logger.h"
#import "PointObj.h"
#import "ProximitySensorProtocol.h"

#ifdef __cplusplus
	#import "b2Physics.h"
	#import "b2ContactDetector.h"
#endif

@interface TouchSwap : EffectProvider <EffectProviderProtocol, ProximitySensorProtocol> 
{
#ifdef __cplusplus
	b2ContactDetector *detector;
#endif
	NSMutableArray *swappers;
	NSMutableArray *finishedSwappers;
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;

- (void) swapTouches:(NSTimer*) theTimer;
- (void) createPairOfSwapsWithUid:(NSNumber*)uid andTarget:(NSNumber*)target;
@end
