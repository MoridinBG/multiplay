//
//  TuioCursor.m
//  Finger
//
//  Created by Ivan Dilchovski on 7/21/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "TuioListener.h"


@implementation TuioListener
@synthesize provider;

- (void) setDimensions:(NSSize) dimensions_
{
	dimensions = dimensions_;
	ratio = dimensions.width / dimensions.height;
}

- (id) init
{
	if (self = [super init])
	{
		tuioClient = [[TuioClient alloc] initWithPortNumber:3333];
		[tuioClient setTuioCursorDelegate:self];
		[tuioClient setTuioObjectDelegate:self];
		
		cursors = [[NSMutableDictionary alloc] initWithCapacity:100];
	}
	return self;
}

- (void) tuioCursorAdded: (TuioCursor*) newCursor
{
	if([cursors count] >= MAX_TOUCHES)
		return;
	
	[Logger logMessage:[NSString stringWithFormat:@"New touch: %d, %f, %f", newCursor.uniqueID,[self transformCoordinates:newCursor.position].x, [self transformCoordinates:newCursor.position].y]
				ofType:DEBUG_LISTENER];
	
	TouchEvent *event = [[TouchEvent alloc] initWithId:[NSNumber numberWithUnsignedInt:newCursor.uniqueID] withType:TouchDown atPos:[self transformCoordinates:newCursor.position]];
	[cursors setObject:event forKey:[NSNumber numberWithUnsignedInt:newCursor.uniqueID]];
	
	[provider processTouches:event];
}

- (void) tuioCursorUpdated: (TuioCursor*) updatedCursor
{
	if(![cursors objectForKey:[NSNumber numberWithUnsignedInt:updatedCursor.uniqueID]])
	   return;
	   
	[Logger logMessage:[NSString stringWithFormat:@"Touch %d moved: %f, %f", updatedCursor.uniqueID, updatedCursor.position.x, updatedCursor.position.y]
				ofType:DEBUG_LISTENER_MOVE];
	TouchEvent *event = [cursors objectForKey:[NSNumber numberWithUnsignedInt:updatedCursor.uniqueID]];
	[event setPos:[self transformCoordinates:updatedCursor.position]];
	[event setType:TouchMove];
	[cursors setObject:event forKey:[NSNumber numberWithUnsignedInt:updatedCursor.uniqueID]];
	
	[provider processTouches:event];
	
}
- (void) tuioCursorRemoved: (TuioCursor*) deadCursor
{
	if(![cursors objectForKey:[NSNumber numberWithUnsignedInt:deadCursor.uniqueID]])
	   return;	
	
	[Logger logMessage:[NSString stringWithFormat:@"Remove touch: %d, %f, %f", deadCursor.uniqueID, deadCursor.position.x, deadCursor.position.y]
				ofType:DEBUG_LISTENER];
	
	TouchEvent *event = [cursors objectForKey:[NSNumber numberWithInt:deadCursor.uniqueID]];
	[cursors removeObjectForKey:[NSNumber numberWithUnsignedInt:deadCursor.uniqueID]];
	[event setPos:[self transformCoordinates:deadCursor.position]];
	[event setType:TouchRelease];
	
	[provider processTouches:event];
}
- (void) tuioCursorFrameFinished
{
}

- (void) tuioObjectAdded: (TuioObject*) newObject
{
}
- (void) tuioObjectUpdated: (TuioObject*) updateObject
{
}
- (void) tuioObjectRemoved: (TuioObject*) deadObject
{
}

- (CGPoint) transformCoordinates:(CGPoint)pos
{
	float oldX = pos.x;
	float oldY = pos.y;

	//Hackintosh Simulator
	float maxX = 1.0f;
	float maxY = 1.0f;
	 
	float minX = 0.0f;
	float minY = 0.0f;
	
	//Prototype
/*	float maxX = 0.848f;
	float maxY = 0.996;
	
	float minX = 0.203f;
	float minY = 0.124f; */

	//Macbook Simulator
/*	float maxX = 1.82f;
	float maxY = 1.50f;
	
	float minX = 1280.0f;
	float minY = 1008.0f; */
	
/*	float newX = (((oldX - minX) * (ratio - (-ratio))) / (maxX - minX)) + (-ratio);
	float newY = (((oldY - minY) * (1.0 - (-1.0))) / (maxY - minY)) + (-1.0); */
	
	//NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
	float newX = (((oldX - minX) * (ratio - 0)) / (maxX - minX)) + 0;
	float newY = (((oldY - minY) * (0 - 1)) / (maxY - minY)) + 1;
//	newY = newY * (-1.0);
	
	CGPoint result = {newX, newY};

	return result;
}
@end
