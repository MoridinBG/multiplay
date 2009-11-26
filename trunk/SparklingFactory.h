//
//  SparklingFactory.h
//  Finger
//
//  Created by Mood on 8/11/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#define BASE_DISTANCE 0.24f
#define BASE_DISLOCATION 0.03f

#import <Cocoa/Cocoa.h>
#import "consts.h"
#import "Sparkle.h"
#import "LiteTouchInfo.h"


@interface SparklingFactory : NSThread 
{
	NSMutableDictionary *timers;
	NSMutableDictionary *positions;
	NSMutableDictionary *sparkleGroups;
	NSMutableDictionary *dieingSparkleGroups;
	
	NSMutableArray *deadSparkles;
	NSMutableArray *deadTouches;
	
	NSRecursiveLock *mutex;
	
}
- (void) main;

- (void) createSparkle:(NSTimer*) theTimer;

- (NSMutableDictionary*) getPositions;
- (void) setPosition:(LiteTouchInfo) touch;
- (void) removePosition:(NSNumber*) uid;
@end
