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
#import "ProximitySensorProtocol.h"

#import "Logger.h"

#ifdef __cplusplus
	#import "b2Physics.h"
	#import "b2ContactDetector.h"
#endif

#import "TargettingInteractor.h"

@interface SineConnect : EffectProvider <EffectProviderProtocol, ProximitySensorProtocol>
{
	NSMutableDictionary *dieingSpots;			//Store ripples for removed touches until animated out
	NSMutableArray *deadSpots;					//We can't modify a container, while enumerating, so temporary put finally dead ripples here
	
	NSMutableArray *sines;						//Travelling sine waves
	NSMutableArray *deadSines;					//Sine waves that have reached their destination
	
	NSMutableArray *sleepingSines;
	NSMutableArray *deadSleepingSines;
	
	NSArray *keys;
	
#ifdef __cplusplus
	b2ContactDetector *detector;
#endif
	
	float f;
	float *sineWave;
	
	float radius;
	float subStep;
	
	float alpha;
	float alphaStep;
	
	float sineVertices[SINECONNECT_NUM_VERTICES * 2];
	int vertexIndex;
}
- (id) init;
- (void) createSineVertexArray;

- (void) processTouches:(TouchEvent*)event;
- (void) render;
@end
