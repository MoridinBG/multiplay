//
//  LineConnect.mm
//  Finger
//
//  Created by Ivan Dilchovski on 9/4/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import "LineConnect.h"


@implementation LineConnect
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Initting a new LineConnect" ofType:DEBUG_GENERAL];

		connections = [[NSMutableArray alloc] initWithCapacity:50];
		dieingConnections = [[NSMutableArray alloc] initWithCapacity:50];
		deadConnections = [[NSMutableArray alloc] initWithCapacity:50];
		
		dieingSpots = [[NSMutableArray alloc] initWithCapacity:100];
		deadSpots = [[NSMutableArray alloc] initWithCapacity:100];
		
		reconnectTimers = [[NSMutableArray alloc] initWithCapacity:100];
		
		radius = 0.08f;
		subStep = 0.039f / 10.0f;
		
		alphaStep = 0.8f / (radius / subStep);
		
		[self createVertexArray];
	}
	return self;
}

- (void) createVertexArray
{
/*	int tmp = 0;
	for(float i = 234.0f; i >= -9.0f; i -= 3.6f)
	{
		vertices[tmp] = (i / 72.0f) / 10.0f;
		vertices[tmp + 1] = sin(i * 10 * DEG2RAD) / 60.0f;
		
		tmp += 2;
	}
	vertexIndex = 0; */
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
	CGPoint oldPos = event.lastPos;
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
			
			[Logger logMessage:@"Processing LineConnect touch down event" ofType:DEBUG_TOUCH];
			
			RGBA color;
			[(NSValue*)[colors objectForKey:uniqueID] getValue:&color];
			
			InteractiveObject *spot = [[InteractiveObject alloc] initWithPos:pos];
			spot.delta = BASE_TOUCH_START_SCALE_DELTA / FRAMES;
			spot.physicsData = [physics addProximityContactListenerAtX:pos.x Y:pos.y withUid:uniqueID];
			spot.color = color;
			
			[touches setObject:spot forKey:uniqueID];
			
			float reconnectInterval = 8 + (arc4random() % 5);
			NSTimer *reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:reconnectInterval
																	   target:self
																	 selector:@selector(reconnect:) 
																	 userInfo:uniqueID
																	  repeats:YES];
			[reconnectTimers addObject:reconnectTimer];
		} break;
			
		case TouchMove:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing LineConnect touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			b2Body* body = (b2Body*)[[touches objectForKey:uniqueID] physicsData];
			
			if(!body)
			{
				[lock unlock];
				return;
			}
			
			body->SetXForm(b2Vec2(pos.x, pos.y), 0.0f);
			
			[(InteractiveObject*)[touches objectForKey:uniqueID] setPosition:pos];
		} break;
			
		case TouchRelease:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing LineConnect touch release event" ofType:DEBUG_TOUCH];
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			if([[touches objectForKey:uniqueID] physicsData])
				[physics destroyBody:(b2Body*)[[touches objectForKey:uniqueID] physicsData]];
			
			InteractiveObject *touch = [touches objectForKey:uniqueID];
			touch.delta = BASE_TOUCH_END_SCALE_DELTA / FRAMES;
			[dieingSpots addObject:touch];
			[touches removeObjectForKey:uniqueID];
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];
	
	[physics step];
	
	TargettingInteractor *connection;
	InteractiveObject *spot;
	NSNumber *uid;

	for(connection in connections)
	{
		float scale = connection.scale;
		
		CGPoint origin;
		CGPoint target;
		CGPoint middle;
		
		RGBA colorOrigin;
		RGBA colorTarget;
		
		if([touches objectForKey:connection.origin])
		{
			origin = [(InteractiveObject*)[touches objectForKey:connection.origin] position];
			connection.originCache = origin;
			colorOrigin = [(InteractiveObject*)[touches objectForKey:connection.origin] color];
			connection.originColorCache = colorOrigin;
		}
		else
		{
			origin = connection.originCache;
			colorOrigin = connection.originColorCache;
		}
		
		if([touches objectForKey:connection.target])
		{
			target = [(InteractiveObject*)[touches objectForKey:connection.target] position];
			connection.targetCache = target;
			colorTarget = [(InteractiveObject*)[touches objectForKey:connection.target] color];
			connection.targetColorCache = colorTarget;
		}
		else
		{
			target = connection.targetCache;
			colorTarget = connection.targetColorCache;	
		}
		
		float a = origin.y - target.y;
		float b = origin.x - target.x;
		float c = sqrt(a*a + b*b);
		
		float oscilation = (0.8f - c) / 100.0f;
		oscilation *= 1.4;
		
		origin.x += ((((float)(arc4random() % 10) / 10) * 2 - 1) * oscilation);
		origin.y += ((((float)(arc4random() % 10) / 10) * 2 - 1) * oscilation);
		 
		target.x += ((((float)(arc4random() % 10) / 10) * 2 - 1) * oscilation);
		target.y += ((((float)(arc4random() % 10) / 10) * 2 - 1) * oscilation);
		
		a = origin.y - target.y;
		b = origin.x - target.x;
		c = sqrt(a*a + b*b);
		float cosine = b / c;		
		
		c /= 4;
		
		float newB = cosine * c;
		float newA = sqrt(c * c - newB * newB);
		if(target.y > origin.y)
			newA = -newA;
		
		middle.x = newB + target.x;
		middle.y = newA + target.y;
		
		
		glLoadIdentity();
		glTranslated(middle.x, middle.y, 0.0);
		glScaled(scale, scale, 1.0);
		glTranslated(-middle.x, -middle.y, 0.0);
		
		glBegin(GL_LINES);
		glColor3f(colorOrigin.r, colorOrigin.g, colorOrigin.b);
		glVertex2f(origin.x, origin.y);
		
		glColor3f(colorTarget.r, colorTarget.g, colorTarget.b);
		glVertex2f(target.x, target.y);
		glEnd();
		
		if(connection.scale < 1.0f)
			connection.scale += 0.2f;
	}
	
	for(connection in dieingConnections)
	{
		glColor3f(1.0f, 1.0f, 1.0f);
		
		float scale = connection.scale;
		
		CGPoint origin;
		CGPoint target;
		CGPoint middle;
		
		RGBA colorOrigin;
		RGBA colorTarget;
		
		if([touches objectForKey:connection.origin])
		{
			origin = [(InteractiveObject*)[touches objectForKey:connection.origin] position];
			connection.originCache = origin;
			colorOrigin = [(InteractiveObject*)[touches objectForKey:connection.origin] color];
		}
		else
		{
			origin = connection.originCache;
			colorOrigin = connection.originColorCache;
		}
		
		if([touches objectForKey:connection.target])
		{
			target = [(InteractiveObject*)[touches objectForKey:connection.target] position];
			connection.targetCache = target;
			colorTarget = [(InteractiveObject*)[touches objectForKey:connection.target] color];
		}
		else
		{
			target = connection.targetCache;
			colorTarget = connection.targetColorCache;	
		}
		
		float a = origin.y - target.y;
		float b = origin.x - target.x;
		float c = sqrt(a*a + b*b);
		
		float cosine = b / c;		
		
		c /= 2;
		
		float newB = cosine * c;
		float newA = sqrt(c * c - newB * newB);
		if(target.y > origin.y)
			newA = -newA;
		
		middle.x = newB + target.x;
		middle.y = newA + target.y;
		
		
		glLoadIdentity();
		glTranslated(middle.x, middle.y, 0.0);
		glScaled(scale, scale, 1.0);
		glTranslated(-middle.x, -middle.y, 0.0);
		
		glBegin(GL_LINES);
		glColor3f(colorOrigin.r, colorOrigin.g, colorOrigin.b);
		glVertex2f(origin.x, origin.y);
		
		glColor3f(colorTarget.r, colorTarget.g, colorTarget.b);
		glVertex2f(target.x, target.y);
		glEnd();
		
		if(connection.scale > 0.0f)
			connection.scale -= 0.1f;
		else
			[deadConnections addObject:connection];
	}
	
	for(connection in deadConnections)
	{
		if([dieingConnections containsObject:connection])
			[dieingConnections removeObject:connection];
	}
	
	[deadConnections removeAllObjects];
	
	for(uid in touches)
	{
		spot = [touches objectForKey:uid];
		[spot randomizeColor];
				
		alpha = 0.8f;
	
		RGBA color = spot.color;
		
		glLoadIdentity();
		glTranslated(spot.position.x, spot.position.y, 0.0);
		glScaled(spot.scale, spot.scale, 1.0);
		glTranslated(-spot.position.x, -spot.position.y, 0.0);
		
		for(float subRadius = 0.001f; subRadius <= radius; subRadius += subStep)
		{
			glColor4f(color.r, color.g, color.b, alpha);
			glBegin(GL_POLYGON);
			for(int i = 0; i <= (SECTORS_TOUCH); i++) 
			{
				glVertex2f(subRadius * cosArray[i] + spot.position.x, 
						   subRadius * sinArray[i] + spot.position.y);
			}
			glEnd();
			alpha -= alphaStep;
		}
		
		//Draw a debug cirlce showing the sensors range
		if(DRAW_PHYSICS_SENSOR_RANGE)
		{
			glColor3f(1.0f, 1.0f, 1.0f);
			glLoadIdentity();
			glBegin(GL_LINE_LOOP);
			for (int i=0; i < 360; i++)
			{
				float degInRad = i * 3.14159f/180.0f;
				glVertex2f(cos(degInRad) * SENSOR_RANGE + spot.position.x, 
						   sin(degInRad) * SENSOR_RANGE + spot.position.y);
			}
			glEnd();
		}
		
		if(spot.isScaling)
		{
			if((spot.scale + spot.delta) > 1.f)														//If the radius is getting too big we should start getting smaller
			{
				spot.scale = 1.f;
				spot.isScaling = FALSE;																//Not scaling anymore
			}
			else
				spot.scale += spot.delta;															//Increment its radius
		}
	}
	
	for(spot in dieingSpots)
	{	
		alpha = 0.8f;
		
		glLoadIdentity();
		glTranslated(spot.position.x, spot.position.y, 0.0);
		glScaled(spot.scale, spot.scale, 1.0);
		glTranslated(-spot.position.x, -spot.position.y, 0.0);
		
		for(float subRadius = 0.001f; subRadius <= radius; subRadius += subStep)
		{
			glColor4f(1.0, 1.0, 1.0, alpha);
			glBegin(GL_POLYGON);
			for(int i = 0; i <= (SECTORS_TOUCH); i++) 
			{
				glVertex2f(subRadius * cosArray[i] + spot.position.x, 
						   subRadius * sinArray[i] + spot.position.y);
			}
			glEnd();
			alpha -= alphaStep;
		}
		
		if(spot.scale >= spot.delta)
		{
			spot.scale -= spot.delta;
		}
		else
			[deadSpots addObject:spot];
	}
	
	for(spot in deadSpots)
	{
		if([dieingSpots containsObject:spot])
			[dieingSpots removeObject:spot];
	}
	
	[deadSpots removeAllObjects];
	[lock unlock];
}
			
- (void) reconnect:(NSTimer*) theTimer
{
	[lock lock];
	NSNumber *uid = [theTimer userInfo];
	if(![touches objectForKey:uid])
	{
		[reconnectTimers removeObject:theTimer];
		[theTimer invalidate];
		
		[lock unlock];
		return;
	}
	
	InteractiveObject *touch = [touches objectForKey:uid];
	if((![touch neighboursCount]) || (![touch connectedNeighboursCount]))
	{
		[lock unlock];
		return;
	}
	
	NSArray *neighbours = [touch getNeighbours];
	NSMutableArray *freeNeighbours = [[NSMutableArray alloc] initWithCapacity:25];
	NSMutableArray *uselessFreeNeighbours = [[NSMutableArray alloc] initWithCapacity:5];
	NSNumber *neighbourUID;
	for(neighbourUID in neighbours)
	{
		if(![touches objectForKey:neighbourUID])
		{
			[touch removeNeighbour:neighbourUID];
			continue;
		}
		if([[touches objectForKey:neighbourUID] connectedNeighboursCount] < 4)
			[freeNeighbours addObject:neighbourUID];
	}
	
	for(neighbourUID in freeNeighbours)
	{
		if([touch hasConnectedNeighbour:neighbourUID])
			[uselessFreeNeighbours addObject:neighbourUID];
	}
	
	for(neighbourUID in uselessFreeNeighbours)
	{
		[freeNeighbours removeObject:neighbourUID];
	}
	[uselessFreeNeighbours removeAllObjects];
	
	if(![freeNeighbours count])
	{
		[lock unlock];
		return;
	}
	
	NSArray *connectedNeighbours = [touch getConnectedNeighbours];
	NSNumber *unluckyConnection = [connectedNeighbours objectAtIndex:(arc4random() % [connectedNeighbours count])];

	TargettingInteractor *connection = [[touches objectForKey:uid] removeConnectedNeighbour:unluckyConnection];
	[[touches objectForKey:unluckyConnection] removeConnectedNeighbour:uid];
	
	[dieingConnections addObject:connection];
	[connections removeObject:connection];
	
	NSNumber *luckyConnection = [freeNeighbours objectAtIndex:(arc4random() % [freeNeighbours count])];
	
	[self updateContactBetween:uid And:luckyConnection];
	[lock unlock];
}

- (void) contactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[lock lock];
	[[touches objectForKey:firstID] addNeighbour:secondID];
	[[touches objectForKey:secondID] addNeighbour:firstID];
	[lock unlock];
}

- (void) updateContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[lock lock];
	[Logger logMessage:[NSString stringWithFormat:@"Contact between touches %d & %d", [firstID intValue], [secondID intValue]] ofType:DEBUG_PHYSICS];
	
	if(([(InteractiveObject*)[touches objectForKey:firstID] connectedNeighboursCount] < 4) && ([(InteractiveObject*)[touches objectForKey:secondID] connectedNeighboursCount] < 4))
	{
		if([(InteractiveObject*)[touches objectForKey:firstID] hasConnectedNeighbour:secondID])
		{
			[lock unlock];
			return;
		}
		
		TargettingInteractor *connection = [[TargettingInteractor alloc] initWithOrigin:firstID target:secondID];
		[connections addObject:connection];
		[[touches objectForKey:firstID] addNeighbour:secondID withConnection:connection];
		[[touches objectForKey:secondID] addNeighbour:firstID withConnection:connection];
	}
	[lock unlock];
}

- (void) removeContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[lock lock];
	[Logger logMessage:[NSString stringWithFormat:@"Removed contact between touches %d & %d", [firstID intValue], [secondID intValue]] ofType:DEBUG_PHYSICS];
	
	[[touches objectForKey:firstID] removeNeighbour:secondID];
	[[touches objectForKey:secondID] removeNeighbour:firstID];
	
	if(![[touches objectForKey:firstID] hasConnectedNeighbour:secondID])
	{
		[lock unlock];
		return;
	}
	
	TargettingInteractor *connection = [[touches objectForKey:firstID] removeConnectedNeighbour:secondID];
	[[touches objectForKey:secondID] removeConnectedNeighbour:firstID];
		
	[dieingConnections addObject:connection];
	[connections removeObject:connection];
	[lock unlock];
}
@end
