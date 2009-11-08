//
//  TouchSwap.m
//  Finger
//
//  Created by Ivan Dilchovski on 11/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "TouchSwap.h"


@implementation TouchSwap
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Init TouchSwap" ofType:DEBUG_GENERAL];
		
		swappers = [[NSMutableArray alloc] initWithCapacity:MAX_TOUCHES];
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
			if(!detector)
			{
				detector = (b2ContactDetector*) [physics addContactDetector];
				if(!physics)
					NSLog(@"Fail");
				detector->setProvider(self);				
			}
			
			[Logger logMessage:@"Processing TouchSwap touch down event" ofType:DEBUG_TOUCH];
			
			InteractiveObject *spot = [[InteractiveObject alloc] init];
			[spot.positionHistoryQueue addObject:[[PointObj alloc] initWithPoint:pos]];
			spot.scale = 1.f;
			spot.physicsData = [physics addProximityContactListenerAtX:pos.x Y:pos.y withUid:uniqueID];
			spot.position = pos;
			
			[touches setObject:spot forKey:uniqueID];
		} break;
		case TouchMove:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing TouchSwap touch move event" ofType:DEBUG_TOUCH_MOVE];
			InteractiveObject *spot = [touches objectForKey:uniqueID];
			spot.position = pos;
			b2Body* body = (b2Body*)spot.physicsData;
			if(!body)
			{
				[lock unlock];
				return;
			}
			else
				body->SetXForm(b2Vec2(pos.x, pos.y), 0.0f);
			
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
			
			[Logger logMessage:@"Processing TouchSwap touch release event" ofType:DEBUG_TOUCH];
			
			if([[touches objectForKey:uniqueID] physicsData])
				[physics destroyBody:(b2Body*)[[touches objectForKey:uniqueID] physicsData]];
			
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
	
	float subStep = 0.039f / 10.0f;
	float alphaStep = 0.8f / (0.08f / subStep);
	for(uid in keys)
	{
		InteractiveObject *spot = [touches objectForKey:uid];
		CGPoint pos = spot.position;
		float alpha = 0.8f;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0);
		glScaled(spot.scale, spot.scale, 1.0);
		glTranslated(-pos.x, -pos.y, 0.0);
		
		//if(!spot.isHolding)
		{
			for(float subRadius = 0.001f; subRadius <= 0.08f; subRadius += subStep)
			{
				glColor4f(color.r, color.g, color.b, alpha);
				glBegin(GL_POLYGON);
				for(int i = 0; i <= (SECTORS_TOUCH); i++) 
				{
					glVertex2f(subRadius * cosArray[i] + pos.x, 
							   subRadius * sinArray[i] + pos.y);
				}
				glEnd();
				alpha -= alphaStep;
			}
		}
		
		if([swappers count])
		{
			CGPoint midPoint = [[[[swappers objectAtIndex:1] trajectory] objectAtIndex:0] getCGPoint];
	//		NSLog(@"%f, %f", midPoint.x, midPoint.y);
			for(float subRadius = 0.001f; subRadius <= 0.08f; subRadius += subStep)
			{
				glColor4f(1, 1, 1, alpha);
				glBegin(GL_POLYGON);
				for(int i = 0; i <= (SECTORS_TOUCH); i++) 
				{
					glVertex2f(subRadius * cosArray[i] + midPoint.x, 
							   subRadius * sinArray[i] + midPoint.y);
				}
				glEnd();
				alpha -= alphaStep;
			}
		}


		//Draw a debug cirlce showing the sensors range
		if(DRAW_PHYSICS_SENSOR_RANGE)
		{
			glColor3f(1.0f, 1.0f, 1.0f);
			glLoadIdentity();
			glBegin(GL_LINE_LOOP);
			for (int i=0; i < 360; i++)
			{
				float degInRad = i * DEG2RAD;
				glVertex2f(cos(degInRad) * SENSOR_RANGE + spot.position.x, 
						   sin(degInRad) * SENSOR_RANGE + spot.position.y);
			}
			glEnd();
		}
		
		if(((spot.lastFramePosition.x == pos.x) && (spot.lastFramePosition.y == pos.y)))
		{
			if((spot.framesStatic >= FRAMES/2) && (!spot.timer) && (!spot.isHolding))
			{
				NSTimer *swapTimer = [NSTimer scheduledTimerWithTimeInterval:SECONDS_BEFORE_SWAP
																	  target:self
																	selector:@selector(swapTouches:)
																	userInfo:uid
																	 repeats:NO];
				spot.timer = swapTimer;
			}
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
			
		
		int count = [spot.positionHistoryQueue count];
		int depth = spot.historyDepth;
		
/*		glLineWidth(6);
		glColor3f(color.r, color.g, color.b);
		glBegin(GL_LINES);		
		for(int i = 0; (i < count - 2) && (i < depth); i++)
		{
			pos = [[spot.positionHistoryQueue objectAtIndex:(count - 3) - i] getCGPoint];
			glVertex2f(pos.x, pos.y);
		}
		glEnd(); */
		
		for(int i = 0; (i < count - 1) && (i < depth); i++)
		{
			pos = [[spot.positionHistoryQueue objectAtIndex:(count - 2) - i] getCGPoint];		
			float disappearFactor = 80.f / PREVIOUS_POSITION_QUEUE_DEPTH;
			alpha = 0.8f - ((i * disappearFactor) / 100.f);
			
			for(float subRadius = 0.001f; subRadius <= 0.08f; subRadius += subStep)
			{
				if(alpha <= 0.f)
					continue;
				glColor4f(color.r, color.g, color.b, alpha);
				glBegin(GL_POLYGON);
				for(int i = 0; i <= (SECTORS_TOUCH); i++) 
				{
					glVertex2f(subRadius * cosArray[i] + pos.x, 
							   subRadius * sinArray[i] + pos.y);
				}
				glEnd();
				alpha -= alphaStep;
			}
		}
	}	
	
	[lock unlock];
}

- (void) swapTouches:(NSTimer*) theTimer
{
	[lock lock];
	InteractiveObject *spot = [touches objectForKey:[theTimer userInfo]];
	
	if((!spot) || (![spot neighboursCount]) || (!spot.framesStatic))
	{
		[theTimer invalidate];
		spot.timer = nil;
		
		[lock unlock];
		return;
	}
	
	NSArray *neighbours = [spot getNeighbours];
	NSMutableArray *freeNeighbours = [[NSMutableArray alloc] initWithCapacity:25];
	NSNumber *neighbourUID;
	for(neighbourUID in neighbours)
	{
		if(![touches objectForKey:neighbourUID])
		{
			[spot removeNeighbour:neighbourUID];
			continue;
		}
		if((![[touches objectForKey:neighbourUID] isHolding]) && ([[touches objectForKey:neighbourUID] framesStatic] >= (FRAMES / 2)))
			[freeNeighbours addObject:neighbourUID];
	}
	
	if(![freeNeighbours count])
	{
		[lock unlock];
		return;
	}
	
	NSNumber *luckyUID = [freeNeighbours objectAtIndex:(arc4random() % [freeNeighbours count])];
	InteractiveObject *targetSpot = [touches objectForKey:luckyUID];
	spot.isHolding = TRUE;
	targetSpot.isHolding = TRUE;
	
	TargettingInteractor *firstSwapper = [[TargettingInteractor alloc] initWithOrigin:[theTimer userInfo] target:luckyUID];
	[firstSwapper calculateTrajectoryWithStart:spot.position andEnd:targetSpot.position];
	
	TargettingInteractor *secondSwapper = [[TargettingInteractor alloc] initWithOrigin:luckyUID target:[theTimer userInfo]];
	[secondSwapper calculateTrajectoryWithStart:targetSpot.position andEnd:spot.position];
	
	[swappers addObject:firstSwapper];
	[swappers addObject:secondSwapper];
	
	[lock unlock];
}

- (void) contactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[lock lock];
	[Logger logMessage:[NSString stringWithFormat:@"Contact between touches %d & %d", [firstID intValue], [secondID intValue]] ofType:DEBUG_PHYSICS];
	
	[[touches objectForKey:firstID] addNeighbour:secondID];
	[[touches objectForKey:secondID] addNeighbour:firstID];
	[lock unlock];
}

- (void) updateContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[lock lock];

	[lock unlock];
}

- (void) removeContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[lock lock];
	[Logger logMessage:[NSString stringWithFormat:@"Removed contact between touches %d & %d", [firstID intValue], [secondID intValue]] ofType:DEBUG_PHYSICS];
	
	[[touches objectForKey:firstID] removeNeighbour:secondID];
	[[touches objectForKey:secondID] removeNeighbour:firstID];
	[lock unlock];
}


@end
