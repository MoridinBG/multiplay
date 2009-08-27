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

#import "ConnectableInteractor.h"
#import "SineWalker.h"

@interface SineConnect : EffectProvider <EffectProviderProtocol>
{
	NSMutableDictionary *spots;
	NSMutableDictionary *dieingSpots;			//Store ripples for removed touches until animated out
	NSDictionary *sines;
	NSMutableArray *deadSpots;				//We can't modify a container, while enumerating, so temporary put finally dead ripples here
	NSMutableArray *sectors[16][10];
	
	NSArray *keys;
	NSNumber *uid;
	
	SineWalker *walker;
	
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
- (NSMutableArray*) collectNeighboursAtX:(int) x Y:(int)y;
@end
