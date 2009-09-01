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
		
		radius = 0.08f;
		subStep = 0.039f / 10.0f;
		
		alphaStep = 0.8f / (radius / subStep);
		
		dieingSpots = [[NSMutableDictionary alloc] initWithCapacity:100];
		deadSpots = [[NSMutableArray alloc] initWithCapacity:100];
		
		sines = [[NSMutableArray alloc] initWithCapacity:100];
		deadSines = [[NSMutableArray alloc] initWithCapacity:100];
		
		sineHolders = [[NSMutableArray alloc] init];
		
		[self createVertexArray];
		
		[physicsThread start];
	}
	return self;
}

- (void) createVertexArray
{
	int tmp = 0;
	for(float i = 234.0f; i >= -9.0f; i -= 3.6f)
	{
		vertices[tmp] = (i / 72.0f) / 10.0f;
		vertices[tmp + 1] = sin(i * 10 * DEG2RAD) / 60.0f;
		
		tmp += 2;
	}
	vertexIndex = 0;
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
			
			if(!body)
				return;
			
			if(body->IsSleeping())
				body->WakeUp();
			body->SetXForm(b2Vec2(pos.x, pos.y), 0.0f);
			
			InteractiveObject *touch  = [touches objectForKey:uniqueID];
			
			if(([sines count] < ([touches count] / 2)) && ([[touch getNeighbours] count]) && ((arc4random() % 10) > 5))
			{
				TargettingInteractor *sine = [[TargettingInteractor alloc] initWithPos:pos];

				NSArray *neighbours = [touch getNeighbours];
				NSNumber *target = [neighbours objectAtIndex:(arc4random() % [neighbours count])];
				
				[sine setOrigin:uniqueID];
				[sine setTarget:target];
				[sine setScale:1.0f];
				
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
	
	glLineWidth(3);
	
	vertexIndex  += 2;
	if (vertexIndex >= 38)
		vertexIndex = 0;
	
	glColor3f(1.0, 1.0, 1.0);
	
	//Draw sines
	for(sine in sines)
	{
		
		if(![touches objectForKey:[sine target]])
		{
			[deadSines addObject:sine];
			continue;
		}
		
		CGPoint begin = [sine position];// [(InteractiveObject*)[touches objectForKey:[sine origin]] position];
		CGPoint end = [(InteractiveObject*)[touches objectForKey:[sine target]] position];
		pos = [sine position];
		
		float a = begin.y - end.y;
		float b = begin.x - end.x;
		float c = sqrt(a*a + b*b);
		
		float cosine = b / c;		
		float angle = acos(cosine);
		
		if(c > 0.2)
			c -= 0.01  ;
		else
		{
			c -= 0.02;
			[sine setScale:([sine scale] - 0.1f)];
			if([sine scale] < 0.2)
			{
				[deadSines addObject:sine];
			}
		}
		
		float newB = cosine * c;
		float newA = sqrt(c * c - newB * newB);
		if(end.y > begin.y)
			newA = -newA;
		
		CGPoint newPosition = {newB + end.x, newA + end.y};
		[sine setPosition:newPosition];
		
		angle *= 57.2958f;
		if(a < 0.0f)
			angle = 360 - angle;
		
		glLoadIdentity();
		glTranslatef(begin.x, begin.y, 0.0f);
		glRotatef(angle, 0.0f, 0.0f, 1.0f);
		glTranslatef(-vertices[vertexIndex], 0.0f, 0.0f);
		
		glBegin(GL_LINE_STRIP);
		for(int i = 0; i < (60 * [sine scale]); i +=2)
		{
			glVertex2f(vertices[i + vertexIndex], vertices[i + vertexIndex + 1]);
		}
		glEnd();
	}
	
	for(sine in deadSines)
	{
		[sines removeObject:sine];
	}
	[deadSines removeAllObjects];
	
	
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
	//	return;
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
