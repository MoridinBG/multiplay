//
//  Ripples.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/31/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#define RIPPLE_RADIUS_FACTOR 0.66
#define RIPPLE_WIDTH_FACTOR 2
#define RIPPLE_ALPHA_FACTOR 0.1

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
