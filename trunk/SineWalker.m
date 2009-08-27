//
//  SineWalker.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/23/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import "SineWalker.h"


@implementation SineWalker
- (void) main
{
	sines = [[NSMutableDictionary alloc] init];
	mutex = [[NSLock alloc] init];
	
	NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.024
													  target:self 
													selector:@selector(step:) 
													userInfo:nil 
													 repeats:YES];
	[myRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
	[myRunLoop run];
}

- (void) step:(NSTimer*) theTimer
{
}

- (void) addSine:(ConnectableInteractor*) sine withUid:(NSNumber*) uid
{
	[mutex lock];
	[sines setObject:sine forKey:uid];
	[mutex unlock];
}

- (NSNumber*) targetForSine:(NSNumber*) uid
{
	[mutex lock];
	NSNumber *target = [[sines objectForKey:uid] targetObject].uid;
	[mutex unlock];
	return target;
}

- (NSDictionary*) getSines
{
	return sines;
}
@end
