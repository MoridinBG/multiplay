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
	mutex = [[NSLock alloc] init];
	
	NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
/*	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.024
													  target:self 
													selector:@selector(step:) 
													userInfo:nil 
													 repeats:YES];
	[myRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];*/
	[myRunLoop run];
	
}

- (void) createSparkle:(NSTimer*) theTimer
{
	[mutex lock];
	CGPoint position;
	CGPoint direction;
	
	struct Sparkle sparkle;
	NSMutableArray *sparkleGroup;
	
	//Calculate a random position around the touch
	[[positions objectForKey:[theTimer userInfo]] getValue:&position];
	
	//A value between -0.08 and 0.08, that is added to the base coordinate
	position.x -= ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.02);
	position.y -= ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.02);
	
	//A value between -0.08 and 0.08 that is used as a direction coordinate
	direction.x = ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.01);
	direction.y = ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.01);
	
	
	//If this would be the first sparkle for this TouchID, create a group
	sparkleGroup = [sparkleGroups objectForKey:[theTimer userInfo]];

	sparkle.position.x = position.x;
	sparkle.position.y = position.y;
	
	sparkle.direction.x = direction.x;
	sparkle.direction.y = direction.y;
	
	sparkle.alpha = 1.0f;
	
	[sparkleGroup addObject:[NSValue value:&sparkle withObjCType:@encode(struct Sparkle)]];
	
	[mutex unlock];
}

- (void) step:(NSTimer*) theTimer
{
	return;
	[mutex lock];
	
	NSArray *uids = [sparkleGroups allKeys];
	NSNumber *uid;
	NSMutableArray *sparkleGroup;
	NSMutableDictionary *groupedPositions = [[NSMutableDictionary alloc] initWithCapacity:([sparkleGroups count] + [dieingSparkleGroups count])];
	struct Sparkle sparkle;
	
	//Iterate over TouchIDs
	for(uid in uids)
	{
		//Get bodies for TouchID
		sparkleGroup = [sparkleGroups objectForKey:uid];
		
		//Iterate over sparkles for this TouchID
		for(int i = 0; i < [sparkleGroup count]; i++)
		{
			[[sparkleGroup objectAtIndex:i] getValue:&sparkle];
			if(sparkle.alpha >= 0.1f)
			{
				sparkle.alpha -= 0.04f;
				sparkle.position.x += sparkle.direction.x;
				sparkle.position.y += sparkle.direction.y;
				[sparkleGroup insertObject:[NSValue value:&sparkle withObjCType:@encode(struct Sparkle)] atIndex:i];
				[sparkleGroup removeObjectAtIndex:(i+1)];
			}
			else
			{
				[sparkleGroup removeObjectAtIndex:i];
				i--;
			}
		}
		[groupedPositions setObject:sparkleGroup forKey:uid];
	}
	
	uids = [dieingSparkleGroups allKeys];
	//Iterate over dieing TouchIDs
	for(uid in uids)
	{
		//Get bodies for TouchID
		sparkleGroup = [dieingSparkleGroups objectForKey:uid];
		
		//Iterate over sparkles for this TouchID
		for(int i = 0; i < [sparkleGroup count]; i++)
		{
			[[sparkleGroup objectAtIndex:i] getValue:&sparkle];
			if(sparkle.alpha >= 0.1f)
			{
				sparkle.alpha -= 0.08f;
				[sparkleGroup insertObject:[NSValue value:&sparkle withObjCType:@encode(struct Sparkle)] atIndex:i];
				[sparkleGroup removeObjectAtIndex:(i+1)];
			}
			else
			{
				[sparkleGroup removeObjectAtIndex:i];
				i--;
			}
		}
		//If all the sparkles in this group have died
		if(![sparkleGroup count])
		{
			[deadSparkles addObject:uid];
		}
		else
		{
			[groupedPositions setObject:sparkleGroup forKey:uid];
		}
	}	
	
	if([deadSparkles count])
		for(unsigned int i = 0; i < [deadSparkles count]; i++)
		{
			NSNumber *uid = [deadSparkles objectAtIndex:i];
			[positions removeObjectForKey:uid];
			[dieingSparkleGroups removeObjectForKey:uid];
		}
	
	[deadSparkles removeAllObjects];
	
	[mutex unlock];
}

- (NSMutableDictionary*) getPositions
{
	[mutex lock];

	NSArray *uids = [sparkleGroups allKeys];
	NSNumber *uid;
	NSMutableArray *sparkleGroup;
	NSMutableDictionary *groupedPositions = [[NSMutableDictionary alloc] initWithCapacity:([sparkleGroups count] + [dieingSparkleGroups count])];
	struct Sparkle sparkle;
	
	//Iterate over TouchIDs
	for(uid in uids)
	{
		//Get bodies for TouchID
		sparkleGroup = [sparkleGroups objectForKey:uid];
		
		
		//Iterate over sparkles for this TouchID
		for(int i = 0; i < [sparkleGroup count]; i++)
		{
			[[sparkleGroup objectAtIndex:i] getValue:&sparkle];
			if(sparkle.alpha >= 0.1f)
			{
				sparkle.alpha -= 0.04f;
				sparkle.position.x += sparkle.direction.x;
				sparkle.position.y += sparkle.direction.y;
				[sparkleGroup insertObject:[NSValue value:&sparkle withObjCType:@encode(struct Sparkle)] atIndex:i];
				[sparkleGroup removeObjectAtIndex:(i+1)];
			}
			else
			{
				[sparkleGroup removeObjectAtIndex:i];
				i--;
			}
		}
		[groupedPositions setObject:sparkleGroup forKey:uid];

	}
	
	uids = [dieingSparkleGroups allKeys];
	//Iterate over dieing TouchIDs
	for(uid in uids)
	{
		//Get bodies for TouchID
		sparkleGroup = [dieingSparkleGroups objectForKey:uid];
		
		//Iterate over sparkles for this TouchID
		for(int i = 0; i < [sparkleGroup count]; i++)
		{
			[[sparkleGroup objectAtIndex:i] getValue:&sparkle];
			if(sparkle.alpha >= 0.1f)
			{
				sparkle.alpha -= 0.08f;
				[sparkleGroup insertObject:[NSValue value:&sparkle withObjCType:@encode(struct Sparkle)] atIndex:i];
				[sparkleGroup removeObjectAtIndex:(i+1)];
			}
			else
			{
				[sparkleGroup removeObjectAtIndex:i];
				i--;
			}
		}
		//If all the sparkles in this group have died
		if(![sparkleGroup count])
		{
			[deadSparkles addObject:uid];
		}
		else
			[groupedPositions setObject:sparkleGroup forKey:uid];

	}	
	
	if([deadSparkles count])
	{
		for(unsigned int i = 0; i < [deadSparkles count]; i++)
		{
			NSNumber *uid = [deadSparkles objectAtIndex:i];
			[positions removeObjectForKey:uid];
			[dieingSparkleGroups removeObjectForKey:uid];
		}
		[deadSparkles removeAllObjects];
	}
	
	[mutex unlock];
	return groupedPositions;
	
}

- (void) setPosition:(LiteTouchInfo) touch
{
	[mutex lock];

	//Set the position for this TouchID
	[positions setObject:[NSValue value:&touch.pos withObjCType:@encode(LiteTouchInfo)] forKey:touch.uid];
	
	if(![sparkleGroups objectForKey:touch.uid])
	{
		NSMutableArray *sparkleGroup = [[NSMutableArray alloc] initWithCapacity:51];
		[sparkleGroups setObject:sparkleGroup forKey:touch.uid];
	}
	
	//If there is no Sparkles creating timer for this TouchID (It's a TouchDown) create it.
	if(![timers objectForKey:touch.uid])
	{
		//Create a new body every 10ms
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.03
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
	
	//Move the sparkles associated to this TouchID to array where to fade away
	[dieingSparkleGroups setObject:[sparkleGroups objectForKey:uid] forKey:uid];
	[[timers objectForKey:uid] invalidate];
	[timers removeObjectForKey:uid];
	[sparkleGroups removeObjectForKey:uid];
	
	[mutex unlock];
}
@end
