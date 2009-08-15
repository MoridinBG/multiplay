//
//  SparklesNonSim.h
//  Finger
//
//  Created by Mood on 8/11/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <math.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import "LiteTouchInfo.h"
#import "SparklingFactory.h"

@interface Sparkles : EffectProvider <EffectProviderProtocol>
{
	NSDictionary *sparkleGroups;
	
	NSArray *sparkleGroup;
	NSValue *sparkleWrapper;
	
	NSArray *keys;
	NSNumber *uid;
	
	SparklingFactory *factory;
	
	int touches;
	
	float radius;
	float subStep;
	
	float alpha;
	float alphaStep;
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;

@end
