//
//  TouchSwap.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//
#define SECONDS_BEFORE_SWAP 1
#define TRAJECTORY_TRAVERSE_STEPS (FRAMES * 2)

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
@end
