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
		finishedSwappers = [[NSMutableArray alloc] initWithCapacity:MAX_TOUCHES];
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
			RGBA color;
			color.a = 0.1f;
			[(NSValue*)[colors objectForKey:uniqueID] getValue:&color];
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
	
	for(TargettingInteractor *swapper in swappers)
	{
		InteractiveObject *origin = [touches objectForKey:swapper.origin];
		InteractiveObject *target = [touches objectForKey:swapper.target];
		
		CGPoint targetPosition;
		CGPoint originPosition;
		
		int startPosition = swapper.startPositionOnTrajectory;
		int endPosition = swapper.endPositionOnTrajectory;
		
		int trajectoryCount = [swapper.trajectory count];
		int historyCount = [swapper.positionHistoryQueue count];
		
		CGPoint pos;
		float scale = 1.f;
	
		glLoadIdentity();
		//Draw trajectory
/*		glColor3f(1.0f, 0.0f, 0.0f);
		glBegin(GL_LINES);			
		for(PointObj *point in [swapper trajectory])
		{
			glVertex2f(point.x, 
					   point.y);
		}
		glEnd(); */
		
		if(origin)
		{
			originPosition = origin.position;
			if((originPosition.x != swapper.originCache.x) || (originPosition.y != swapper.originCache.y))
			{
				swapper.originCache = originPosition;
			}
		}

		if(target)
		{
			targetPosition = target.position;
			if((targetPosition.x != swapper.targetCache.x) || (targetPosition.y != swapper.targetCache.y))
			{
				swapper.targetCache = targetPosition;
				if(startPosition)
				{
					[swapper.positionHistoryQueue addObject:[[PointObj alloc] initWithPoint:targetPosition]];
					historyCount++;
				} else
				{
					[swapper calculateBezierTrajectoryWithStart:swapper.position 
														 andEnd:targetPosition];
				}
			}
		} else if(!swapper.isAimless)
		{
			swapper.isAimless = TRUE;
			swapper.newColor = origin.color;
			swapper.newColor.a = 0.f;
			[swapper calcColorChangeInSteps:endPosition];
		}
		
		if((historyCount < trajectoryCount) && (!swapper.isAimless) && (endPosition < trajectoryCount))
		{
			if(endPosition)
			{
				[swapper.positionHistoryQueue addObject:[swapper.trajectory objectAtIndex:(endPosition - 1)]];
				historyCount++;
			}
			[swapper.positionHistoryQueue addObject:[swapper.trajectory objectAtIndex:endPosition]];
			historyCount++;
		}
		
		for(int i = 0; i < startPosition; i++)
		{
			[swapper.positionHistoryQueue removeObjectAtIndex:i];
			historyCount--;
		}
		swapper.startPositionOnTrajectory = 0;
		for (PointObj *point in swapper.positionHistoryQueue)
		{
			pos = [point getCGPoint];
			glLoadIdentity();
			glTranslated(pos.x, pos.y, 0.f);
			glScaled(scale, scale, 1);
			glTranslated(-pos.x, -pos.y, 0.f);
			scale -= 1.f / (historyCount);
			
			[swapper renderCircularTouchAtPosition:pos withSectors:SECTORS_TOUCH withWhite:FALSE];
		}
		
		if(endPosition < historyCount)
		{
			swapper.endPositionOnTrajectory += 2;
		} else if (startPosition < historyCount)
		{
			swapper.startPositionOnTrajectory += 2;
		} else 
		{
			target.isHolding = FALSE;
			[finishedSwappers addObject:swapper];
		}

		
		[swapper stepColors];
	}
	for(TargettingInteractor *deadSwapper in finishedSwappers)
		[swappers removeObject:deadSwapper];
	[finishedSwappers removeAllObjects];
	
	NSArray *keys = [touches allKeys];
	NSNumber *uid;
	
	for(uid in keys)
	{
		InteractiveObject *spot = [touches objectForKey:uid];
		CGPoint pos = spot.position;
		
		RGBA color = spot.color;
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0);
		glScaled(spot.scale, spot.scale, 1.0);
		glTranslated(-pos.x, -pos.y, 0.0);
		
		if(!spot.isHolding)
		{
			[spot renderCircularTouchWithSectors:SECTORS_TOUCH withWhite:FALSE];
		} else
			//If the spot is travelling at the moment
		{
			float side = (2 * TOUCH_RADIUS) / sqrt(2.0f);
			
			CGPoint upl = pos;
			upl.x -= side / 2;
			upl.y += side / 2;
			
			CGPoint upr = pos;
			upr.x += side / 2;
			upr.y += side / 2;
			
			CGPoint downl = pos;
			downl.x -= side / 2;
			downl.y -= side / 2;
			
			CGPoint downr = pos;
			downr.x += side / 2;
			downr.y -= side / 2;
			
			glLineWidth(6);
			glLoadIdentity();
			glBegin(GL_LINES);
			
			glColor4f(color.r, color.g, color.b, 0.f);
			glVertex2f(upl.x, upl.y);
			glColor4f(color.r, color.g, color.b, 0.8f);
			glVertex2f(pos.x, pos.y);
			
			glColor4f(color.r, color.g, color.b, 0.f);
			glVertex2f(downl.x, downl.y);
			glColor4f(color.r, color.g, color.b, 0.8f);
			glVertex2f(pos.x, pos.y);
			
			glColor4f(color.r, color.g, color.b, 0.f);
			glVertex2f(downr.x, downr.y);
			glColor4f(color.r, color.g, color.b, 0.8f);
			glVertex2f(pos.x, pos.y);
			
			glColor4f(color.r, color.g, color.b, 0.f);
			glVertex2f(upr.x, upr.y);
			glColor4f(color.r, color.g, color.b, 0.8f);
			glVertex2f(pos.x, pos.y);
			
			glEnd(); 
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
		
		int count = [spot.positionHistoryQueue count] - 1;
		if(count > 15)
		{
			float x = 0;
			float y = 0;
			CGPoint reference = [[spot.positionHistoryQueue objectAtIndex:(count - (FRAMES / 2))] getCGPoint];
			for(int i = count - ((FRAMES / 2) - 1); i < count; i++)
			{
				CGPoint pos = [[spot.positionHistoryQueue objectAtIndex:i] getCGPoint];
				x += reference.x - pos.x;
				y += reference.y - pos.y;
			}
		}
		
		if(((spot.lastFramePosition.x == pos.x) && (spot.lastFramePosition.y == pos.y)))
		{
			if((spot.framesStatic >= FRAMES/2) && (!spot.timer) && (!spot.isHolding))
			{
				//				float swapTime = MIN_SECONDS_BEFORE_SWAP + (arc4random() % MAX_SECONDS_BEFORE_SWAP - MIN_SECONDS_BEFORE_SWAP);
				NSTimer *swapTimer = [NSTimer scheduledTimerWithTimeInterval:1
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
		
		if((spot.lastFramePosition.x != pos.x) || (spot.lastFramePosition.y != pos.y))
		{
			if(spot.historyDepth < PREVIOUS_POSITION_QUEUE_DEPTH)
				spot.historyDepth++;
			spot.framesStatic = 0;
		}
		
		spot.lastFramePosition = pos;
		
/*		glLineWidth(6);																				//Dashed line trail
		glColor3f(color.r, color.g, color.b);
		glBegin(GL_LINES);		
		for(int i = 0; (i < count - 2) && (i < depth); i++)
		{
			pos = [[spot.positionHistoryQueue objectAtIndex:(count - 3) - i] getCGPoint];
			glVertex2f(pos.x, pos.y);
		}
		glEnd(); //*/
		
		int historyCount = [spot.positionHistoryQueue count] - 1;
		int depth = spot.historyDepth;
		
		if(!spot.isHolding)
		{
			float scale = 1.f;
			float step = 1.f / depth;
			CGPoint position;
			for(int i = 0; (i < historyCount) && (i < depth); i++)
			{
				position = [[spot.positionHistoryQueue objectAtIndex:historyCount - i] getCGPoint];		
				glLoadIdentity();
				glTranslated(position.x, position.y, 0.0);
				glScaled(scale, scale, 1.0);
				glTranslated(-position.x, -position.y, 0.0);
				scale -= step;
				
				[spot renderCircularTouchAtPosition:position withSectors:SECTORS_TOUCH withWhite:FALSE];
			}
		}
	}	
	
	[lock unlock];
}

- (void) swapTouches:(NSTimer*) theTimer
{
	[lock lock];
	InteractiveObject *spot = [touches objectForKey:[theTimer userInfo]];
	
	if((!spot) || (![spot neighboursCount]) || (!spot.framesStatic) || (spot.isHolding))
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
		{
			[freeNeighbours addObject:neighbourUID];
		}
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
	
	[self createPairOfSwapsWithUid:[theTimer userInfo] andTarget:luckyUID];
	[self createPairOfSwapsWithUid:[theTimer userInfo] andTarget:luckyUID];
	[self createPairOfSwapsWithUid:[theTimer userInfo] andTarget:luckyUID];
	
	spot.timer = nil;
	
	[lock unlock];
}

- (void) createPairOfSwapsWithUid:(NSNumber*)uid andTarget:(NSNumber*)target;
{
	InteractiveObject *targetSpot = [touches objectForKey:target];
	InteractiveObject *spot = [touches objectForKey:uid];
	spot.isHolding = TRUE;
	targetSpot.isHolding = TRUE;
	
	float curving;
	float controlPointDistance;
	
	do
	{
		curving = BEZIER_MIN_CURVING / 10.f + ((arc4random() % BEZIER_MAX_CURVING - BEZIER_MIN_CURVING) / 10.f);
	} while (curving > BEZIER_MAX_CURVING);
	
	do 
	{
		controlPointDistance = BEZIER_MIN_CONTROL_POINT_DISTANCE / 10.f + ((arc4random() % BEZIER_MAX_CONTROL_POINT_DISTANCE - BEZIER_MIN_CONTROL_POINT_DISTANCE) / 10.f);
	} while (controlPointDistance > BEZIER_MAX_CONTROL_POINT_DISTANCE);
	
	TargettingInteractor *firstSwapper = [[TargettingInteractor alloc] initWithOrigin:uid target:target];
	firstSwapper.curving = curving;
	firstSwapper.controlPointDistance =   		 controlPointDistance;
	
	[firstSwapper calculateBezierTrajectoryWithStart:spot.position andEnd:targetSpot.position];
	firstSwapper.position = spot.position;
	firstSwapper.originCache = spot.position;
	firstSwapper.targetCache = targetSpot.position;
	
	RGBA color = spot.color;
	RGBA newColor = targetSpot.color;
	
	firstSwapper.color = color;
	firstSwapper.newColor = newColor;
	[firstSwapper calcColorChangeInSteps:TRAJECTORY_TRAVERSE_STEPS];	
	
	TargettingInteractor *secondSwapper = [[TargettingInteractor alloc] initWithOrigin:target target:uid];
	secondSwapper.curving = curving;
	secondSwapper.controlPointDistance = controlPointDistance;
	
	[secondSwapper calculateBezierTrajectoryWithStart:targetSpot.position andEnd:spot.position];
	secondSwapper.position = targetSpot.position;
	secondSwapper.originCache = targetSpot.position;
	secondSwapper.targetCache = spot.position;
	
	color = targetSpot.color;
	newColor = spot.color;
	
	secondSwapper.color = color;
	secondSwapper.newColor = newColor;
	[secondSwapper calcColorChangeInSteps:TRAJECTORY_TRAVERSE_STEPS];
	
	[swappers addObject:firstSwapper];
	[swappers addObject:secondSwapper];
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
