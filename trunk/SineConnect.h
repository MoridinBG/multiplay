//
//  SineConnect.h
//  Finger
//
//  Created by Mood on 8/13/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <math.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import "Logger.h"

#ifdef __cplusplus
	#import "b2Physics.h"
	#import "b2ContactDetector.h"
#endif

#import "TargettingInteractor.h"

@interface SineConnect : EffectProvider <EffectProviderProtocol>
{
	NSMutableDictionary *dieingSpots;			//Store ripples for removed touches until animated out
	NSMutableArray *sines;
	NSMutableArray *deadSpots;				//We can't modify a container, while enumerating, so temporary put finally dead ripples here
	
	NSArray *keys;
	
#ifdef __cplusplus
	b2ContactDetector *detector;
#endif
	
	float f;
	float *sineWave;
	float degrad;
	
	float radius;
	float subStep;
	
	float alpha;
	float alphaStep;
}
- (void) processTouches:(TouchEvent*)event;
- (void) render;

- (void) contactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;
- (void) updateContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;
- (void) removeContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;

@end
