//
//  TouchTrail.m
//  Finger
//
//  Created by Ivan Dilchovski on 11/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "TouchTrail.h"


@implementation TouchTrail
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Init TouchTrail" ofType:DEBUG_GENERAL];
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
	CGPoint lastPos = event.lastPos;
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Processing TouchTrail touch down event" ofType:DEBUG_TOUCH];
			
			RGBA color;
			[(NSValue*)[colors objectForKey:uniqueID] getValue:&color];
			
			InteractiveObject *spot = [[InteractiveObject alloc] init];
			[spot.positionHistoryQueue addObject:[[PointObj alloc] initWithPoint:pos]];
			spot.scale = 1.f;
			spot.position = pos;
			spot.color = color;
			
			[touches setObject:spot forKey:uniqueID];
		} break;
		case TouchMove:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing TouchTrail touch move event" ofType:DEBUG_TOUCH_MOVE];
			InteractiveObject *spot = [touches objectForKey:uniqueID];
			spot.position = pos;
			
			[spot.positionHistoryQueue addObject:[[PointObj alloc] initWithPoint:lastPos]];
			if([spot.positionHistoryQueue count] > MAX_PREVIOUS_POSITION_QUEUE_DEPTH)
				[spot.positionHistoryQueue removeObjectAtIndex:0];
		} break;
		case TouchRelease:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing TouchTrail touch release event" ofType:DEBUG_TOUCH];
			
			[touches removeObjectForKey:uniqueID];
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];
	
	[physics step];
	glDisable(GL_TEXTURE_2D);
	
	NSArray *keys = [touches allKeys];
	NSNumber *uid;
	
	for(uid in keys)
	{
		InteractiveObject *spot = [touches objectForKey:uid];
		CGPoint pos = spot.position;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0);
		glScaled(spot.scale, spot.scale, 1.0);
		glTranslated(-pos.x, -pos.y, 0.0);
		
		[spot renderCircularTouchWithSectors:SECTORS_TOUCH withWhite:FALSE];
		
		if(((spot.lastFramePosition.x == pos.x) && (spot.lastFramePosition.y == pos.y)))
		{
			if(spot.historyDepth > 0)
				spot.historyDepth -= 2;
			spot.framesStatic++;
		}
		
		if(((spot.lastFramePosition.x != pos.x) || (spot.lastFramePosition.y != pos.y)) && (spot.historyDepth < PREVIOUS_POSITION_QUEUE_DEPTH))
		{
			spot.historyDepth++;
			spot.framesStatic = 0;
		}
		
		spot.lastFramePosition = pos;
			
		
		int count = [spot.positionHistoryQueue count] - 1;
		int depth = spot.historyDepth;
		
		glLineWidth(6);																				//Dashed line trail
		glColor3f(color.r, color.g, color.b);
		glBegin(GL_LINES);		
		for(int i = 0; (i < count - 2) && (i < depth); i++)
		{
			pos = [[spot.positionHistoryQueue objectAtIndex:(count - 3) - i] getCGPoint];
			glVertex2f(pos.x, pos.y);
		}
		glEnd();
		
/*		float scale = 1.f;
		float step = 1.f / depth;
		CGPoint position;
		for(int i = 0; (i < count) && (i < depth); i++)
		{
			position = [[spot.positionHistoryQueue objectAtIndex:count - i] getCGPoint];		
			glLoadIdentity();
			glTranslated(position.x, position.y, 0.0);
			glScaled(scale, scale, 1.0);
			glTranslated(-position.x, -position.y, 0.0);
			scale -= step;
			
			[spot renderCircularTouchAtPosition:position withSectors:SECTORS_TOUCH withWhite:FALSE];
		} */
	}	
	
	[lock unlock];
}
@end
