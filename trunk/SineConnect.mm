//
//  SineConnect.m
//  Finger
//
//  Created by Mood on 8/13/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "SineConnect.h"


@implementation SineConnect
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Initting a new SineConnect" ofType:DEBUG_GENERAL];
		f = 0.0f;
		
		radius = 0.19f;
		subStep = 0.039f / 4.0f;
		
		alphaStep = 0.8f / (radius / subStep);
		
		dieingSpots = [[NSMutableDictionary alloc] initWithCapacity:100];
		deadSpots = [[NSMutableArray alloc] initWithCapacity:100];
		
		sines = [[NSMutableArray alloc] initWithCapacity:100];
		
		[physicsThread start];
	}
	return self;
}

- (void) processTouches:(TouchEvent*)event
{
	[super processTouches:event];
	
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
				detector->setProvider(self);
			}
			
			[Logger logMessage:@"Process sine touch down event" ofType:DEBUG_TOUCH];

			if((pos.x < -1.60f) || (pos.x > 1.60f) || (pos.y < -1.0f) || (pos.y > 1.0f))
			{
				[Logger logMessage:@"Touch out of range" ofType:DEBUG_GENERAL];
				return;
			}
			
			TargettingInteractor *spot = [[TargettingInteractor alloc] initWithPos:pos];
			[spot setDelta:0.1];
			[spot setPhysicsData:[(b2Physics*)physicsThread addContactListenerAtX:pos.x Y:pos.y withUid:uniqueID]];
			
			[touches setObject:spot forKey:uniqueID];
			
		
		} break;
			
		case TouchMove:
		{
			[Logger logMessage:@"Process sine touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			b2Body* body = (b2Body*)[[touches objectForKey:uniqueID] physicsData];
			
			if(body->IsSleeping())
				body->WakeUp();
			body->SetXForm(b2Vec2(pos.x, pos.y), 0.0f);
			
			InteractiveObject *touch  = [touches objectForKey:uniqueID];
			
			if(([sines count] < ([touches count] / 2)) && ([[touch getNeighbours] count]))
			{
				TargettingInteractor *sine = [[TargettingInteractor alloc] initWithPos:pos];

				NSArray *neighbours = [touch getNeighbours];
				NSNumber *target = [neighbours objectAtIndex:(arc4random() % [neighbours count])];
				
				[sine setOrigin:uniqueID];
				[sine setTarget:target];
				
				[sines addObject:sine];
			}
			
			[touch setPosition:pos];
		} break;
			
		case TouchRelease:
		{
			[Logger logMessage:@"Process sine touch release event" ofType:DEBUG_TOUCH];
			
			[(b2Physics*) physicsThread destroyBody:(b2Body*)[[touches objectForKey:uniqueID] physicsData]];
			[dieingSpots setObject:[touches objectForKey:uniqueID] forKey:uniqueID];
			[touches removeObjectForKey:uniqueID];
		} break;
	}
}

- (void) render
{
	InteractiveObject *spot;
	float scale;
	CGPoint pos;
	float delta;
	bool isScaling;
	NSNumber *uid;
	TargettingInteractor *sine;
	

	glLineWidth(2);
	
	//Draw sines
	for(sine in sines)
	{
		
		CGPoint begin = [(InteractiveObject*)[touches objectForKey:[sine origin]] position];
		CGPoint end = [(InteractiveObject*)[touches objectForKey:[sine target]] position];
		
		float a = begin.y - end.y;
		float b = begin.x - end.x;
		float c = sqrt(a*a + b*b);
		
		float angle = acos(b/c);
		angle *=57.2958f;
		
		if(a < 0.0f)
			angle = 360 - angle;

		glLoadIdentity();
		glTranslatef(end.x, end.y, 0.0f);
		glRotatef(angle, 0.0f, 0.0f, 1.0f);
		glTranslatef(-(f/10), 0.0f, 0.0f);
		
		glColor3f(1.0, 1.0, 1.0);
		glBegin(GL_LINE_STRIP);
		for(float i = f; i <= (f + (c * 10.0f)); i += 0.2f)
		{
			glVertex2f(i / 10, sin(i * 360 * (PI/180.0f)) / 24);
		}
		glEnd();
	}
	
/*	//Debug sectors network
	glLineWidth(1);
	glLoadIdentity();
	glColor3f(1.0f, 0.0f, 0.0f);
	for(float i = 1.0f; i < 16.0f; i += 1.0f)
	{
		glBegin(GL_LINES);
		glVertex2f(-1.60f + (i * (3.20f / 16.0f)), -1.0f);
		glVertex2f(-1.60f + (i * (3.20f / 16.0f)), 1.0f);
		glEnd();
	}
	for(float i = 1.0f; i < 10.0f; i += 1.0f)
	{
		glBegin(GL_LINES);
		glVertex2f(-1.60f, -1.0f + (i * (2.0f / 10.0f)));
		glVertex2f(1.60f, -1.0f + (i * (2.0f / 10.0f)));
		glEnd();
	}
	glLineWidth(4); */
	
	keys = [touches allKeys];
	if((![keys count]) && (![[dieingSpots allKeys] count]))
	{
		[colors removeAllObjects];
		return;
	}
	
	for(uid in keys	)																//Draw alive touches
	{
		spot = [touches objectForKey:uid];
		scale = [spot scale];
		pos = [spot position];
		delta = [spot delta];
		isScaling = [spot isScaling];
		
		alpha = 0.8f;
		
		//Scale
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0);
		glScaled(scale, scale, 1.0);
		glTranslated(-pos.x, -pos.y, 0.0);
		
		for(float subRadius = 0.001f; subRadius <= radius; subRadius += subStep)
		{
			glColor4f(1.0f, 1.0f, 1.0f, alpha);
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
		
		glColor3f(1.0f, 1.0f, 1.0f);
		glLoadIdentity();
		glBegin(GL_LINE_LOOP);
		for (int i=0; i < 360; i++)
		{
			float degInRad = i * 3.14159f/180.0f;
			glVertex2f(cos(degInRad) * SENSOR_RANGE + pos.x, sin(degInRad) * SENSOR_RANGE + pos.y);
		}
		glEnd();
		
		if(isScaling)
		{
			
			scale += delta;															//Increment its radius
			if(scale >= 1.0f)														//If the radius is getting too big we should start getting smaller
			{
				if([spot isNew])													//If the ripple has gotten so big for the first time decrement the scaling step
				{
					[spot setIsNew:FALSE];
					[spot setDelta:0.01];
				}
				isScaling = !isScaling;												//Not scaling anymore
			}
		} else
		{
			scale -= delta;															//Decrement the radius
			if (scale < 0.7)														//If the radius is too small start incrementing
			{
				isScaling = !isScaling;
			}
		}
		
		[spot setScale:scale];														//Update current ripple's parameters		
		[spot setIsScaling:isScaling];												//Update current ripple's parameters
	}
	
	
	keys = [dieingSpots allKeys];
	for(uid in keys)																//Iterrate over spots with removed touches and suck them out
	{
		spot = [dieingSpots objectForKey:uid];
		scale = [spot scale];
		pos = [spot position];
		
		alpha = 0.8f;
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0);
		glScaled(scale, scale, 1.0);
		glTranslated(-pos.x, -pos.y, 0.0);
		
		for(float subRadius = 0.001f; subRadius <= radius; subRadius += subStep)
		{
			glColor4f(1.0f, 1.0f, 1.0f, alpha);
			glBegin(GL_POLYGON);
			for(int i = 0; i <= (SECTORS_TOUCH); i++) 
			{
				glVertex2f(subRadius * cosArray[i] + pos.x, 
						   subRadius * sinArray[i] + pos.y);
			}
			glEnd();
			
			alpha -= alphaStep;
		}
		
		scale -= 0.1f;
		if(scale <= 0.1f)
		{
			[deadSpots addObject:uid];												//We can't modify a container while enumerating, so reference the dead object in another container
			continue;
		}
		[spot setScale:scale];
	}
	
	for(uid in deadSpots)															//Iterrate the dead ripples and remove them forever
	{
		[dieingSpots removeObjectForKey:uid];
	}
	[deadSpots removeAllObjects];
	
	f += 0.1f;
	if(f == 1.0f)
		f = 0.0f; 
}

- (void) contactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
		NSLog(@"Here");
	[[touches objectForKey:firstID] addNeighbour:secondID];
	[[touches objectForKey:secondID] addNeighbour:firstID];
}

- (void) updateContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
}

- (void) removeContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
	[[touches objectForKey:firstID] removeNeighbour:secondID];
	[[touches objectForKey:secondID] removeNeighbour:firstID];
}

@end
