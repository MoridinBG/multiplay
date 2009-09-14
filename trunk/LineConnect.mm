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
		
		radius = 0.08f;
		subStep = 0.039f / 10.0f;
		
		alphaStep = 0.8f / (radius / subStep);
		
		[self createVertexArray];
		[physicsThread start];
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
	[super processTouches:event];
	
	if([event ignoreEvent])
		return;
	
	NSNumber *uniqueID = event.uid;
	CGPoint pos = event.pos;
	CGPoint oldPos = event.lastPos;
	switch (event.type) 
	{
		case TouchDown:
		{
			if(!detector)
			{
				detector = (b2ContactDetector*) [(b2Physics*) physicsThread addContactDetector];
				if(!physicsThread)
					NSLog(@"Fail");
				detector->setProvider(self);				
			}
			
			[Logger logMessage:@"Process LineConnect touch down event" ofType:DEBUG_TOUCH];
			
			RGBA color;
			[(NSValue*)[colors objectForKey:uniqueID] getValue:&color];
			
			InteractiveObject *spot = [[InteractiveObject alloc] initWithPos:pos];
			[spot setDelta:0.15];
			[spot setPhysicsData:[(b2Physics*)physicsThread addContactListenerAtX:pos.x Y:pos.y withUid:uniqueID]];
			[spot setColor:color];
			
			[touches setObject:spot forKey:uniqueID];		
		} break;
			
		case TouchMove:
		{
			[Logger logMessage:@"Process LineConnect touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			b2Body* body = (b2Body*)[[touches objectForKey:uniqueID] physicsData];
			
			if(!body)
				return;
			
			if(body->IsSleeping())
				body->WakeUp();
			body->SetXForm(b2Vec2(pos.x, pos.y), 0.0f);
			
			[(InteractiveObject*)[touches objectForKey:uniqueID] setPosition:pos];
		} break;
			
		case TouchRelease:
		{
			[Logger logMessage:@"Process LineConnect touch release event" ofType:DEBUG_TOUCH];
			
			[(b2Physics*) physicsThread destroyBody:(b2Body*)[[touches objectForKey:uniqueID] physicsData]];
			[dieingSpots addObject:[touches objectForKey:uniqueID]];
			[touches removeObjectForKey:uniqueID];
		} break;
	}
}

- (void) render
{
	TargettingInteractor *connection;
	InteractiveObject *spot;
	float scale;
	CGPoint pos;
	NSNumber *uid;
	float delta;
	bool isScaling;
	
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
		}
		else
			origin = connection.originCache;
		
		if([touches objectForKey:connection.target])
		{
			target = [(InteractiveObject*)[touches objectForKey:connection.target] position];
			connection.targetCache = target;
			colorTarget = [(InteractiveObject*)[touches objectForKey:connection.target] color];
		}
		else
			target = connection.targetCache;
		
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
		
		if(connection.scale < 1.0f)
			connection.scale += 0.1f;
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
			origin = connection.originCache;
		
		if([touches objectForKey:connection.target])
		{
			target = [(InteractiveObject*)[touches objectForKey:connection.target] position];
			connection.targetCache = target;
			colorTarget = [(InteractiveObject*)[touches objectForKey:connection.target] color];
		}
		else
			target = connection.targetCache;
		
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
		[dieingConnections removeObject:connection];
	}
	
	[deadConnections removeAllObjects];
	
	for(uid in touches)
	{
		spot = [touches objectForKey:uid];
		scale = [spot scale];
		pos = [spot position];
		delta = [spot delta];
		isScaling = [spot isScaling];
		
		[spot randomizeColor];
				
		alpha = 0.8f;
	
		RGBA color = [spot color];
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0);
		glScaled(scale, scale, 1.0);
		glTranslated(-pos.x, -pos.y, 0.0);
		
		for(float subRadius = 0.001f; subRadius <= radius; subRadius += subStep)
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
		
		//Draw a debug cirlce showing the sensors range
/*		glColor3f(1.0f, 1.0f, 1.0f);
		glLoadIdentity();
		glBegin(GL_LINE_LOOP);
		for (int i=0; i < 360; i++)
		{
			float degInRad = i * 3.14159f/180.0f;
			glVertex2f(cos(degInRad) * SENSOR_RANGE + pos.x, sin(degInRad) * SENSOR_RANGE + pos.y);
		}
		glEnd(); */
		
		if(isScaling)
		{
			scale += delta;														//Increment its radius
			[spot setScale:scale];
			if(scale >= 1.01f)													//If the radius is getting too big we should start getting smaller
			{
				[spot setScale:1.0f];
				isScaling = FALSE;												//Not scaling anymore
			}
		}
	}
	
	for(spot in dieingSpots)
	{
		scale = [spot scale];
		pos = [spot position];
		
		alpha = 0.8f;
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0);
		glScaled(scale, scale, 1.0);
		glTranslated(-pos.x, -pos.y, 0.0);
		
		for(float subRadius = 0.001f; subRadius <= radius; subRadius += subStep)
		{
			glColor4f(1.0, 1.0, 1.0, alpha);
			glBegin(GL_POLYGON);
			for(int i = 0; i <= (SECTORS_TOUCH); i++) 
			{
				glVertex2f(subRadius * cosArray[i] + pos.x, 
						   subRadius * sinArray[i] + pos.y);
			}
			glEnd();
			alpha -= alphaStep;
		}
		
		if(scale >= 0.1f)
		{
			scale -= 0.15f;
			[spot setScale:scale];
		}
		else
			[deadSpots addObject:spot];
	}
	
	for(spot in deadSpots)
	{
		[dieingSpots removeObject:spot];
	}
	
	[deadSpots removeAllObjects];
}

- (void) contactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{

}

- (void) updateContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[Logger logMessage:[NSString stringWithFormat:@"Contact between touches %d & %d", [firstID intValue], [secondID intValue]] ofType:DEBUG_PHYSICS];
	
	if(([(InteractiveObject*)[touches objectForKey:firstID] connectedNeighboursCount] < 4) && ([(InteractiveObject*)[touches objectForKey:secondID] connectedNeighboursCount] < 4))
	{
		if([(InteractiveObject*)[touches objectForKey:firstID] hasConnectedNeighbour:secondID])
			return;
		
		TargettingInteractor *connection = [[TargettingInteractor alloc] initWithOrigin:firstID target:secondID];
		[connections addObject:connection];
		[[touches objectForKey:firstID] addNeighbour:secondID withConnection:connection];
		[[touches objectForKey:secondID] addNeighbour:firstID withConnection:connection];
	}
}

- (void) removeContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[Logger logMessage:[NSString stringWithFormat:@"Removed contact between touches %d & %d", [firstID intValue], [secondID intValue]] ofType:DEBUG_PHYSICS];
	
	TargettingInteractor *connection = [[touches objectForKey:firstID] removeConnectedNeighbour:secondID];
	[[touches objectForKey:secondID] removeConnectedNeighbour:firstID];
	
	if(!connection)
		return;
	
	[dieingConnections addObject:connection];
	[connections removeObject:connection];
}
@end
