//
//  PacMan.m
//  Finger
//
//  Created by Ivan Dilchovski on 11/25/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "PacMan.h"


@implementation PacMan
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Init PacMan" ofType:DEBUG_GENERAL];
	}
	return self;
}

- (void) processTouches:(TouchEvent*)event
{
	[lock lock];
	[super processTouches:event];
	
	if([event ignoreEvent])
	{
		[lock unlock];
		return;
	}
	
	NSNumber *uniqueID = event.uid;
	CGPoint pos = event.pos;
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Processing PacMan touch down event" ofType:DEBUG_TOUCH];
			
			RGBA color;
			[(NSValue*)[colors objectForKey:uniqueID] getValue:&color];
			
			InteractiveObject *spot = [[InteractiveObject alloc] init];
			spot.scale = 1.f;
			spot.position = pos;
			spot.color = color;
			
			[touches setObject:spot forKey:uniqueID];
		} break;
		case TouchMove:
		{
			[Logger logMessage:@"Processing PacMan touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			InteractiveObject *spot = [touches objectForKey:uniqueID];
			spot.position = pos;
		} break;
		case TouchRelease:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing PacMan touch release event" ofType:DEBUG_TOUCH];

			[touches removeObjectForKey:uniqueID];
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];
	InteractiveObject *spot;
	
	for(spot in touches)
	{
		glLoadIdentity();
		[spot renderCircularTouchWithSectors:SECTORS_TOUCH withWhite:FALSE];
	}
		
	
	[lock unlock];
}
@end
