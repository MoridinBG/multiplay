//
//  Ripples.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/31/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#define RIPPLE_RADIUS_FACTOR 0.5
#define RIPPLE_WIDTH_FACTOR 2
#define RIPPLE_ALPHA_FACTOR 0.1
#define RIPPLE_COLOR_CHANGE_SPEED 22.f
#define RIPPLE_APPEAR_TIME_FACTOR 5
#define DONUT_ALPHA_DELTA_FACTOR 1.5f

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import "ClusteredInteractor.h"
#import "Logger.h"

@interface Ripples : EffectProvider <EffectProviderProtocol> 
{
	NSMutableDictionary *dieingTouches;
	NSMutableArray *deadTouches;
	NSMutableDictionary *newTouches;
	NSMutableDictionary *donuts;
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;
@end
