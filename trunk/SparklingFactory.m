//
//  SparklingFactory.m
//  Finger
//
//  Created by Mood on 8/11/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "SparklingFactory.h"


@implementation SparklingFactory
- (void) main
{
	timers = [[NSMutableDictionary alloc] initWithCapacity:MAX_TOUCHES];
	sparkleGroups = [[NSMutableDictionary alloc] initWithCapacity:MAX_TOUCHES];
	dieingSparkleGroups = [[NSMutableDictionary alloc] initWithCapacity:MAX_TOUCHES];
	positions = [[NSMutableDictionary alloc] initWithCapacity:MAX_TOUCHES];
	
	deadSparkles = [[NSMutableArray alloc] initWithCapacity:30];
	deadTouches = [[NSMutableArray alloc] initWithCapacity:100];
	mutex = [[NSRecursiveLock alloc] init];
	
	NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
	[myRunLoop run];
	
}

- (void) createSparkle:(NSTimer*) theTimer
{
	CGPoint position;
	CGPoint direction;
	
	Sparkle *sparkle;
	NSMutableArray *sparkleGroup;
	
	//Calculate a random position around the touch
	[[positions objectForKey:[theTimer userInfo]] getValue:&position];
	
	//A value between -0.08 and 0.08, that is added to the base coordinate
	position.x -= ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.02);
	position.y -= ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.02);
	
	//A value between -0.08 and 0.08 that is used as a direction coordinate
	direction.x = ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.012);
	direction.y = ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.012);
	
	
	//If this would be the first sparkle for this TouchID, create a group
	sparkleGroup = [sparkleGroups objectForKey:[theTimer userInfo]];
	
	sparkle = [[Sparkle alloc] initAtPosition:position withDirection:direction withAlpha:1.0f];
	[sparkleGroup addObject:sparkle];
}

- (NSMutableDictionary*) getPositions
{
	[mutex lock];

	NSArray *keys = [sparkleGroups allKeys];
	NSNumber *touchUID;
	NSMutableArray *sparkleGroup;
	Sparkle *sparkle;
	
	//Iterate over TouchIDs
	for(touchUID in keys)
	{
		[self createSparkle:[timers objectForKey:touchUID]];
		//Get bodies for TouchID
		sparkleGroup = [sparkleGroups objectForKey:touchUID];
		[deadSparkles removeAllObjects];
		
		//Iterate over sparkles for this TouchID
		for(sparkle in sparkleGroup)
		{
			if(sparkle.alpha >= 0.1f)
			{
				CGPoint position = sparkle.position;
				CGPoint direction = sparkle.direction;
				
				position.x += direction.x;
				position.y += direction.y;
				
				sparkle.position = position;
				sparkle.direction = direction;
				
				sparkle.alpha -= 0.06f;
			}
			else
			{
				[deadSparkles addObject:sparkle];
			}
		}
		if([deadSparkles count])
		{
			for(sparkle in deadSparkles)
			{
				[sparkleGroup removeObject:sparkle];
			}
			
			[deadSparkles removeAllObjects];
		}
	}
	
	keys = [dieingSparkleGroups allKeys];
	//Iterate over dieing TouchIDs
	for(touchUID in keys)
	{
		//Get bodies for TouchID
		sparkleGroup = [dieingSparkleGroups objectForKey:touchUID];
		[deadSparkles removeAllObjects];
		
		//Iterate over sparkles for this TouchID
		for(sparkle in sparkleGroup)
		{
			if(sparkle.alpha >= 0.1f)
			{
				sparkle.alpha -= 0.08f;
			}
			else
			{
				[deadSparkles addObject:sparkle];
			}
		}
		
		if([deadSparkles count])
		{
			for(sparkle in deadSparkles)
			{
				[sparkleGroup removeObject:sparkle];
			}
			
			[deadSparkles removeAllObjects];
		}
		
		//If all the sparkles in this group have died
		if(![sparkleGroup count])
		{
			[deadTouches addObject:touchUID];
		}
	}
	
	if([deadTouches count])
	{
		for(touchUID in deadTouches)
		{
			[dieingSparkleGroups removeObjectForKey:touchUID];
		}
		[deadTouches removeAllObjects];
	}
	
	
	[mutex unlock];
	return sparkleGroups;
	
}

- (void) setPosition:(LiteTouchInfo) touch
{
	[mutex lock];

	if((!touch.isTouchDown) && (![[positions allKeys] containsObject:touch.uid]))
	{
//		[mutex unlock];
//		return;
	}
	
	//Set the position for this TouchID
	[positions setObject:[NSValue value:&touch.pos withObjCType:@encode(LiteTouchInfo)] forKey:touch.uid];
	
	if(![sparkleGroups objectForKey:touch.uid])
	{
		NSMutableArray *sparkleGroup = [[NSMutableArray alloc] initWithCapacity:51];
		[sparkleGroups setObject:sparkleGroup forKey:touch.uid];
	}
	
	//If there is no Sparkles-creating timer for this TouchID (It's a TouchDown) create it.
	if(![timers objectForKey:touch.uid])
	{
		//Create a new body every 10ms
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.04
														  target:self 
														selector:@selector(createSparkle:)
														userInfo:touch.uid
														 repeats:YES];
		[timers setObject:timer forKey:touch.uid];
	}
	[mutex unlock];
}

- (void) removePosition:(NSNumber*) uid
{
	[mutex lock];
	
	if(![[sparkleGroups allKeys] containsObject:uid])
	{
		[mutex unlock];
		return;
	}
	
	//Move the sparkles associated to this TouchID to array where to fade away
	[dieingSparkleGroups setObject:[sparkleGroups objectForKey:uid] forKey:uid];
	[[timers objectForKey:uid] invalidate];
	[timers removeObjectForKey:uid];
	[sparkleGroups removeObjectForKey:uid];
	
	[mutex unlock];
}
@end
