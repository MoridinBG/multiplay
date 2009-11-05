//
//  TuioMultiplexor.m
//  Finger
//
//  Created by Mood on 9/2/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "TuioMultiplexor.h"


@implementation TuioMultiplexor
@synthesize provider;

- (id) init
{
	if(self = [super init])
	{
		numSenders = 1;
	}
	
	return self;
}

- (void) cursorAddedEvent: (TouchEvent*) event
{
	long offset = [self calculateOffset:[[event uid] longValue]];
	
	event.lastPos = [self transformCoordinates:[event lastPos] forPortOffset:offset];
	[event setPos:[self transformCoordinates:[event pos] forPortOffset:offset]];
	
	[Logger logMessage:[NSString stringWithFormat:@"New touch %d at %f, %f", [event.uid intValue], event.pos.x, event.pos.y]
				ofType:DEBUG_LISTENER];
	
	[provider processTouches:event];
}

- (void) cursorUpdatedEvent: (TouchEvent*) event
{	
	long offset = [self calculateOffset:[[event uid] longValue]];

	event.lastPos = [self transformCoordinates:event.lastPos forPortOffset:offset];
	event.pos = [self transformCoordinates:event.pos forPortOffset:offset];
	
	[Logger logMessage:[NSString stringWithFormat:@"Moved touch %d to %f, %f", [event.uid intValue], event.pos.x, event.pos.y]
				ofType:DEBUG_LISTENER_MOVE];	
	
	[provider processTouches:event];
}

- (void) cursorRemovedEvent: (TouchEvent*) event;
{	
	long offset = [self calculateOffset:[[event uid] longValue]];
	
	event.lastPos = [self transformCoordinates:[event lastPos] forPortOffset:offset];	
	[event setPos:[self transformCoordinates:[event pos] forPortOffset:offset]];
	
	[Logger logMessage:[NSString stringWithFormat:@"Removed touch %d from %f, %f", [event.uid intValue], event.pos.x, event.pos.y]
				ofType:DEBUG_LISTENER];
	
	[provider processTouches:event];
}

- (CGPoint) transformCoordinates:(CGPoint)coordinates forPortOffset:(int) offset
{
	float segment = ratio / numSenders;
	
	float oldX = coordinates.x;
	float oldY = coordinates.y;
	
	float maxX = segment + (offset * segment);
	float minX = maxX - segment;

	float maxY = 0.f;
	float minY = 1.f;
	
	float oldMaxX, oldMaxY, oldMinX, oldMinY;
	
	if(SIMULATOR)
	{
		//Simulator
		oldMaxX = 1.0f;
		oldMaxY = 1.0f;
		
		oldMinX = 0.0f;
		oldMinY = 0.0f;
	}
	else
	{
		//Prototype
		oldMaxX = 0.848f;
		oldMaxY = 0.996;
		
		oldMinX = 0.227f;
		oldMinY = 0.124f;
	}
	
	//NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
	float newX = (((oldX - oldMinX) * (maxX - minX)) / (oldMaxX - oldMinX)) + minX;
	float newY = (((oldY - oldMinY) * (maxY - minY)) / (oldMaxY - oldMinY)) + minY;
	
	CGPoint result = {newX, newY};
	
	return result;
}

- (void) setDimensions:(CGSize) dimensions_
{
	dimensions = dimensions_;
	ratio = dimensions.width / dimensions.height;
}

- (long) calculateOffset:(long) uid
{
	if(numSenders == 1)
		return 0;
	else
	{
		long offset;
		for(offset = 0; uid > 0; offset++)
			uid -= 10000000;
		offset--;
		
		return offset;
	}
}

@end
