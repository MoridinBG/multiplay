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

- (id) initWithListeners:(int) listeners
{
	numSenders = 1;
	if(self = [super init])
	{
	}
	
	return self;
}

- (void) cursorAddedEvent: (TouchEvent*) event
{
	[Logger logMessage:[NSString stringWithFormat:@"New touch %d at %f, %f", [event.uid intValue], event.pos.x, event.pos.y]
				ofType:DEBUG_LISTENER];
	
	int offset = [self calculateOffset:[[event uid] intValue]];
	[event setPos:[self transformCoordinates:[event pos] forPortOffset:offset]];
	
	[provider processTouches:event];
}

- (void) cursorUpdatedEvent: (TouchEvent*) event
{
	[Logger logMessage:[NSString stringWithFormat:@"Moved touch %d to %f, %f", [event.uid intValue], event.pos.x, event.pos.y]
				ofType:DEBUG_LISTENER_MOVE];
	
	int offset = [self calculateOffset:[[event uid] intValue]];
	[event setPos:[self transformCoordinates:[event pos] forPortOffset:offset]];
	
	[provider processTouches:event];
}

- (void) cursorRemovedEvent: (TouchEvent*) event;
{	
	int offset = [self calculateOffset:[[event uid] intValue]];
	[event setPos:[self transformCoordinates:[event pos] forPortOffset:offset]];
	
	[Logger logMessage:[NSString stringWithFormat:@"Removed touch %d from %f, %f", [event.uid intValue], event.pos.x, event.pos.y]
				ofType:DEBUG_LISTENER];

	[provider processTouches:event];
}

- (CGPoint) transformCoordinates:(CGPoint)pos forPortOffset:(int) offset
{
	float oldX = pos.x;
	float oldY = pos.y;
	
	float segment = ratio / numSenders;
	
	float maxX = segment + (offset * segment);
	float minX = maxX - segment;
	
	//Hackintosh Simulator
	float oldMaxX = 1.0f;
	float oldMaxY = 1.0f;
	
	float oldMinX = 0.0f;
	float oldMinY = 0.0f;
	
	//Prototype
/*	 float oldMaxX = 0.848f;
	 float oldMaxY = 0.996;
	 
	 float oldMinX = 0.227f;
	 float oldMinY = 0.124f; */
	
	//Macbook Simulator
	/*	float oldMaxX = 1.82f;
	 float oldMaxY = 1.50f;
	 
	 float oldMinX = 1280.0f;
	 float oldMinY = 1008.0f; */
	
	//NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
	float newX = (((oldX - oldMinX) * (maxX - minX)) / (oldMaxX - oldMinX)) + minX;
	float newY = (((oldY - oldMinY) * (0 - 1)) / (oldMaxY - oldMinY)) + 1;
	
	CGPoint result = {newX, newY};
	
	return result;
}

- (void) setDimensions:(NSSize) dimensions_
{
	dimensions = dimensions_;
	ratio = dimensions.width / dimensions.height;
}

- (int) calculateOffset:(int) uid
{
	if(numSenders == 1)
		return 0;
	
	unsigned int offset;
	for(offset = 0; uid > 0; offset++)
		uid -= 10000000;
	offset--;

	return offset;
}

@end
