//
//  SparklingFactory.h
//  Finger
//
//  Created by Mood on 8/11/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

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
	
	NSLock *mutex;
	
}
- (void) main;

- (void) step:(NSTimer*) theTimer;
- (void) createSparkle:(NSTimer*) theTimer;

- (NSMutableDictionary*) getPositions;
- (void) setPosition:(LiteTouchInfo) touch;
- (void) removePosition:(NSNumber*) uid;
@end
