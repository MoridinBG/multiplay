//
//  TuioCursor.m
//  Finger
//
//  Created by Ivan Dilchovski on 7/21/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "TuioListener.h"


@implementation TuioListener
@synthesize multiplexor;

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
	
	TouchEvent *event = [[TouchEvent alloc] initWithId:[NSNumber numberWithUnsignedInt:newCursor.uniqueID] withType:TouchDown atPos:newCursor.position];
	[cursors setObject:event forKey:[NSNumber numberWithUnsignedInt:newCursor.uniqueID]];
	
	[multiplexor cursorAddedEvent:event];
}

- (void) tuioCursorUpdated: (TuioCursor*) updatedCursor
{
	if(![cursors objectForKey:[NSNumber numberWithUnsignedInt:updatedCursor.uniqueID]])
	   return;

	TouchEvent *event = [cursors objectForKey:[NSNumber numberWithUnsignedInt:updatedCursor.uniqueID]];
	[event setPos:updatedCursor.position];
	[event setType:TouchMove];
	[cursors setObject:event forKey:[NSNumber numberWithUnsignedInt:updatedCursor.uniqueID]];
	[event setIgnoreEvent:FALSE];
	
	[multiplexor cursorUpdatedEvent:event];
	
}
- (void) tuioCursorRemoved: (TuioCursor*) deadCursor
{
	if(![cursors objectForKey:[NSNumber numberWithUnsignedInt:deadCursor.uniqueID]])
	   return;	
	
	TouchEvent *event = [cursors objectForKey:[NSNumber numberWithInt:deadCursor.uniqueID]];
	[cursors removeObjectForKey:[NSNumber numberWithUnsignedInt:deadCursor.uniqueID]];
	[event setPos:deadCursor.position];
	[event setType:TouchRelease];
	[event setIgnoreEvent:FALSE];
	
	[multiplexor cursorRemovedEvent:event];
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
@end
