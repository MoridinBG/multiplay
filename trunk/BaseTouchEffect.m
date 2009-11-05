//
//  CLASS_NAME.m
//  Finger
//
//  Created by Ivan Dilchovski on 11/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "BaseTouchEffect.h"


@implementation CLASS_NAME
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Init CLASS_NAME" ofType:DEBUG_GENERAL];
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
			[Logger logMessage:@"Processing CLASS_NAME touch down event" ofType:DEBUG_TOUCH];
			
			InteractiveObject *touch = [[InteractiveObject alloc] init];
			
			[touches setObject:touch forKey:uniqueID];
		} break;
		case TouchMove:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing CLASS_NAME touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			[(InteractiveObject*)[touches objectForKey:uniqueID] setPosition:pos];
		} break;
		case TouchRelease:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing CLASS_NAME touch release event" ofType:DEBUG_TOUCH];

			[touches removeObjectForKey:uniqueID];
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];

	[lock unlock];
}
@end
