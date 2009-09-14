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
		
		sleepingSines = [[NSMutableArray alloc] init];
		deadSleepingSines = [[NSMutableArray alloc] init];
		
		[self createSineVertexArray];
		[physicsThread start];
	}
	return self;
}

- (void) createSineVertexArray
{
	int tmp = 0;
	for(float i = 234.0f; i >= -9.0f; i -= 3.6f)
	{
		sineVertices[tmp] = (i / 72.0f) / 7.0f;
		sineVertices[tmp + 1] = sin(i * 10 * DEG2RAD) / 70.0f;
		
		tmp += 2;
	}
	vertexIndex = 0;
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
				detector->setProvider(self);				
			}
			
			[Logger logMessage:@"Process sine touch down event" ofType:DEBUG_TOUCH];
			
			InteractiveObject *spot = [[InteractiveObject alloc] initWithPos:pos];
			spot.delta = 0.2f;
			[spot setPhysicsData:[(b2Physics*)physicsThread addContactListenerAtX:pos.x Y:pos.y withUid:uniqueID]];
			
			if((([sines count] + [sleepingSines count]) <= ([touches count] / 2)))
			{
				TargettingInteractor *sine = [[TargettingInteractor alloc] initWithPos:pos];
				
				[sine setOrigin:uniqueID];
				[sleepingSines addObject:sine];
				spot.isHolding = TRUE;
			}
			
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
			
			[(InteractiveObject*)[touches objectForKey:uniqueID] setPosition:pos];
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
	bool isHolding;
	NSNumber *uid;
	TargettingInteractor *sine;
	
	glLineWidth(3);
	
	vertexIndex  += 2;
	if (vertexIndex >= 38)
		vertexIndex = 0;
	
	glColor3f(1.0, 1.0, 1.0);
	
	for(sine in sleepingSines)
	{
		if(![touches objectForKey:sine.origin])
		{
			NSLog(@"Here");
			[deadSleepingSines addObject:sine];
			continue;
		}
		
		NSArray *neighbours = [[touches objectForKey:sine.origin] getNeighbours];
		if(![neighbours count])
			continue;
		
		sine.isNew = TRUE;
		sine.scale = 0.0;
		
		NSNumber *target = [neighbours objectAtIndex:(arc4random() % [neighbours count])];
		sine.target = target;
		[sine setPosition:[(InteractiveObject*)[touches objectForKey:sine.origin] position]];
		((InteractiveObject*)[touches objectForKey:sine.origin]).isHolding = FALSE;
		
		[sines addObject:sine];
	}
	
	if([deadSleepingSines count])
	{
		for(sine in deadSleepingSines)
		{
			[sleepingSines removeObject:sine];
		}
		
		[deadSleepingSines removeAllObjects];
	}
	
	//Draw sines
	for(sine in sines)
	{
		if([sleepingSines containsObject:sine])
			[sleepingSines removeObject:sine];
		
		CGPoint begin = [sine position];
		CGPoint end;
		float sineSpeed = 0.025;
		
		if([touches objectForKey:[sine target]])
		{
			sine.targetCache = ((InteractiveObject*)[touches objectForKey:sine.target]).position;
			end = [(InteractiveObject*)[touches objectForKey:[sine target]] position];
		}
		else
		{
			CGPoint hyperspace;
			if(((sine.targetCache.x <= 1.6) && (sine.targetCache.x >= 0.0)) && ((sine.targetCache.y <= 1.0) &&  (sine.targetCache.y >= 0.0)))
			{
				hyperspace = sine.targetCache;
				CGPoint origin = sine.targetCache;
				CGPoint target = sine.position;
				
				float a = origin.y - target.y;
				float b = origin.x - target.x;
				float c = sqrt(a*a + b*b);
				float cosine = b / c;
				
				do
				{
					c += 0.1;
					
					float newB = cosine * c;
					float newA = sqrt(c * c - newB * newB);
					if(target.y > origin.y)
							newA = -newA;
					
					hyperspace.x = newB + target.x;
					hyperspace.y = newA + target.y;
				} while(((hyperspace.x <= 1.6) && (hyperspace.x >= 0.0)) && ((hyperspace.y <= 1.0) &&  (hyperspace.y >= 0.0)));
				sine.targetCache = hyperspace;
			}
			end = sine.targetCache;
			sineSpeed = 0.08;
		}
		
		pos = [sine position];
		
		RGBA color;
		[(NSValue*)[colors objectForKey:[sine target]] getValue:&color];
		
		float a = begin.y - end.y;
		float b = begin.x - end.x;
		float c = sqrt(a*a + b*b);
		
		float cosine = b / c;		
		float angle = acos(cosine);
		
		
		if(c > (0.2 * sine.scale))
		{
			c -= sineSpeed;
			
			if(sine.isNew)
			{
				sine.scale += 0.09f;
				if(sine.scale >= 1.0f)
				{
					sine.isNew = FALSE;
					sine.scale = 1.0f;
				}
			}
		}
		else
		{
			c -= 0.02;
			sine.scale -= 0.1f;
			if(sine.scale < 0.2)
			{
				[sine setOrigin:[sine target]];
				[sleepingSines addObject:sine];
				((InteractiveObject*)[touches objectForKey:[sine origin]]).isHolding = TRUE;
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
		
		alpha = 0.0f;
		
		glLoadIdentity();
		glTranslatef(begin.x, begin.y, 0.0f);
		glRotatef(angle, 0.0f, 0.0f, 1.0f);
		glTranslatef(-sineVertices[vertexIndex], 0.0f, 0.0f);
		
		glBegin(GL_LINE_STRIP);
		for(int i = 0; i < (60 * [sine scale]); i +=2)
		{
			glColor4f(color.r, color.g, color.b, alpha);
			alpha += 0.025f;
			glVertex2f(sineVertices[i + vertexIndex], sineVertices[i + vertexIndex + 1]);
		}
		glEnd();
	}
	
	for(sine in deadSines)
	{
		[sines removeObject:sine];
	}
	[deadSines removeAllObjects];
	
	keys = [touches allKeys];
	if((![keys count]) && (![[dieingSpots allKeys] count]))
	{
		[colors removeAllObjects];
	//	return;
	}
	
	for(uid in keys	)																//Draw alive touches
	{
		spot = [touches objectForKey:uid];
		scale = spot.scale;
		pos = spot.position;
		delta = spot.delta;
		isScaling = spot.isScaling;
		isHolding = spot.isHolding;
		
		if(isHolding)
		{
			pos.x += ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.003);
			pos.y += ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.003);
		}
		
		alpha = 0.8f;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		//Scale
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
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
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
		
		scale -= 0.25f;
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
