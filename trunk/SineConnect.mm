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
		
		radius = 0.08f;
		subStep = 0.039f / 10.0f;
		
		alphaStep = 0.8f / (radius / subStep);
		
		dieingSpots = [[NSMutableDictionary alloc] initWithCapacity:100];
		deadSpots = [[NSMutableArray alloc] initWithCapacity:100];
		
		sines = [[NSMutableArray alloc] initWithCapacity:100];
		deadSines = [[NSMutableArray alloc] initWithCapacity:100];
		
		sleepingSines = [[NSMutableArray alloc] init];
		deadSleepingSines = [[NSMutableArray alloc] init];
		
		[self createSineVertexArray];																		//Prerender a sine wave in array of vertex coordinates
	}
	return self;
}

- (void) createSineVertexArray																				//Store the coordinates as pairs in plain C array
{
	int tmp = 0;
	for(float i = 234.0f; i >= -9.0f; i -= 3.6f)
	{
		sineVertices[tmp] = (i / 72.0f) / 7.0f;
		sineVertices[tmp + 1] = sin(i * 10 * DEG2RAD) / 70.0f;
		
		tmp += 2;
	}
	vertexIndex = 0;																						//We draw only part of the sine by moving a starting offset. It begins from 0
}

- (void) processTouches:(TouchEvent*)event
{
	[lock lock];
	[super processTouches:event];
	
	if([event ignoreEvent])
		return;
	
	NSNumber *uniqueID = event.uid;
	CGPoint pos = event.pos;
	
	switch (event.type) 
	{
		case TouchDown:
		{
			if(!detector)																					//If there is no contact detector set yet, set a new one
			{
				detector = (b2ContactDetector*) [physics addContactDetector];
				detector->setProvider(self);				
			}
			
			[Logger logMessage:@"Processing SineConnect touch down event" ofType:DEBUG_TOUCH];
			
			InteractiveObject *spot = [[InteractiveObject alloc] initWithPos:pos];
			spot.scale = 0.f;
			spot.delta = (spot.targetScale - spot.scale) / (FRAMES / 2);
			[spot setPhysicsData:[physics addProximityContactListenerAtX:pos.x Y:pos.y withUid:uniqueID]];	//Create a contact detector for the new touch
			
			RGBA color;
			[(NSValue*)[colors objectForKey:uniqueID] getValue:&color];
			spot.color = color;
			spot.scale = 0.f;
			
			if((([sines count] + [sleepingSines count]) <= ([touches count] * 0.75)))						//If there are less than three quarters sines than touches, then create a new sine
			{
				TargettingInteractor *sine = [[TargettingInteractor alloc] initWithPos:pos];
				
				[sine setOrigin:uniqueID];
				[sleepingSines addObject:sine];																//The sine has no target yet
				spot.isHolding = TRUE;																		//The touch holds the sine
				spot.itemsHeld = 1;
			}
			
			[touches setObject:spot forKey:uniqueID];		
		} break;
			
		case TouchMove:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing SineConnect touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			b2Body* body = (b2Body*)[[touches objectForKey:uniqueID] physicsData];							//Get the contact detector from the touch
			
			if(!body)
				return;

			body->SetXForm(b2Vec2(pos.x, pos.y), 0.0f);														//And move it
			
			[(InteractiveObject*)[touches objectForKey:uniqueID] setPosition:pos];							//Update the touch position
		} break;
			
		case TouchRelease:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing SineConnect touch release event" ofType:DEBUG_TOUCH];
			
			[physics destroyBody:(b2Body*)[[touches objectForKey:uniqueID] physicsData]];					//Destroy the touche's physics detector
			InteractiveObject *touch = [touches objectForKey:uniqueID];
			touch.delta = BASE_TOUCH_END_SCALE_DELTA / FRAMES;
			[dieingSpots setObject:touch forKey:uniqueID];													//Mark the touch as dieing
			[touches removeObjectForKey:uniqueID];															//Remove it from the list of active touches
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];
	
	[physics step];																							//Advance the physics engine with one step
	
	InteractiveObject *spot;
	NSNumber *uid;
	TargettingInteractor *sine;
	
	glLineWidth(5);																							//Make the sines thick
	
	vertexIndex  += 2;																						//Move the startting offset each frame, so that sines appear animated
	if (vertexIndex >= 38)																					//When we reach the end (calculated from the current index + length of the sine) start from 0 again
		vertexIndex = 0;
	
	for(sine in sleepingSines)																				//Iterate over sine sleeping inside touches
	{
		if(![touches objectForKey:sine.origin])																//If the touch holding the sine is removed reference it in a container for removal (fast enumeration)
		{
			[deadSleepingSines addObject:sine];
			continue;
		}
		
		InteractiveObject *touch = [touches objectForKey:sine.origin];
		
		NSArray *neighbours = [touch getNeighbours];														//Get the neighbours of the holding touch
		if(![neighbours count])																				//If there are no neighbours the sine will continue to sleep
			continue;
		
		sine.isNew = TRUE;																					//The sine starts as newborn
		sine.scale = 0.0;																					//And has no length yet
		
		
		NSNumber *target = [neighbours objectAtIndex:(arc4random() % [neighbours count])];					//Get a random target sine
		sine.target = target;
		[sine setPosition:[touch position]];																//Get the position of the holding touch
		
		touch.itemsHeld--;																					//The holding touch now holds one sine less
		if(!touch.itemsHeld)																				//If there are no more held sines
			touch.isHolding = FALSE;																		//The touch is no more a holder
		
		sine.color = ((InteractiveObject*) [touches objectForKey:target]).color;																			//Set the sine's color to the target's color
		
		[sines addObject:sine];																				//Put the sine in the list of active sines
	}
	
	if([deadSleepingSines count])																			//Remove sines marked as dead
	{
		for(sine in deadSleepingSines)
		{
			[sleepingSines removeObject:sine];
		}
		
		[deadSleepingSines removeAllObjects];
	}
	
	for(sine in sines)																						//Draw sines
	{
		if([sleepingSines containsObject:sine])																//If the sine is still in the list of sleeping sines
			[sleepingSines removeObject:sine];
		
		CGPoint begin = [sine position];
		CGPoint end;
		
		float sineSpeed = BASE_SINE_SPEED / FRAMES;															//The speed with wich sines move
		
		if([touches objectForKey:[sine target]])															//If the target touch is still alive
		{
			sine.targetCache = ((InteractiveObject*)[touches objectForKey:sine.target]).position;			//Cache it's current position
			end = [(InteractiveObject*)[touches objectForKey:[sine target]] position];						//Set it as a target
		}
		else if(!sine.isAimless)																			//If the touch is removed and there is no hyperspace position calculated yet
		{
			CGPoint hyperspace;
			if(((sine.targetCache.x <= 4.8) && (sine.targetCache.x >= 0.0)) && ((sine.targetCache.y <= 1.0) &&  (sine.targetCache.y >= 0.0)))	//If the sine is still in the rendering space
			{
				hyperspace = sine.targetCache;																//Hold a value outside of the drawing space, on the line connecting the sine with the target's cached position
				CGPoint origin = sine.targetCache;															//Use the cached position of the target as a direction
				CGPoint target = sine.position;
				
				float a = origin.y - target.y;																//With some trigonometry find the line connecting current and target position
				float b = origin.x - target.x;																//And it's angle with the X axis
				float c = sqrt(a*a + b*b);
				float cosine = b / c;
				
				do
				{
					c += 0.1;																				//Make the connecting line a little bit longer
					
					float newB = cosine * c;																//Calculate the new values of the sine target 
					float newA = sqrt(c * c - newB * newB);
					if(target.y > origin.y)																	//A fix if the sine is under the target (otherwise there are some nasty rotations)
							newA = -newA;
					
					hyperspace.x = newB + target.x;															//Move the hyperspace posittion a little
					hyperspace.y = newA + target.y;
				} while(((hyperspace.x <= 1.6) && (hyperspace.x >= 0.0)) && ((hyperspace.y <= 1.0) &&  (hyperspace.y >= 0.0)));					//Loop while the hyperspace position is inside the drawing space
				sine.targetCache = hyperspace;																//Hyperspace is the new target
			}
			end = sine.targetCache;
			sineSpeed = BASE_SINE_SPEED * 5 / FRAMES;
			
			sine.isAimless = TRUE;																			//This is the first time the sine has no target
			sine.target = nil;																				//Invalidate the target
		} else
		{
			end = sine.targetCache;																			//The hyperspace coordinates are precomputed
			sineSpeed = BASE_SINE_SPEED * 5 / FRAMES;														//Set to warp speed
		}
		RGBA color = sine.color;
		
		float a = begin.y - end.y;																			//Calculate a line between the sine and it's target position
		float b = begin.x - end.x;
		float c = sqrt(a*a + b*b);
		
		float cosine = b / c;		
		float angle = acos(cosine);
		
		if(c > (0.2 * sine.scale))																			//If the sine is not too close to the target
		{
			c -= sineSpeed;																					//Shorten the distance a little bit at normal speed
			
			if(sine.isNew)																					//If the sine is new (not at it's full length) it should grow
			{
				sine.scale += 0.09f;
				if(sine.scale >= 1.0f)																		//Grow until normal size and then set as old
				{
					sine.isNew = FALSE;
					sine.scale = 1.0f;
				}
			}
		}
		else																								//When the sine gets close to the target it should speed up
		{
			c -= sineSpeed / 2;																				//Shorten the distance at lower speed
			sine.scale -= 0.1f;																				//Scale down
			
			if((sine.scale <= 0.1f) || (c <= 0))															//The sine has got sucked in. Remove from list of active sines, make the target touch a holder
			{
				if(sine.target)																				//If the target is not a point in the hyperspace put the sine to sleep in the target touch
				{
					[sine setOrigin:[sine target]];
					[sleepingSines addObject:sine];
					((InteractiveObject*)[touches objectForKey:[sine origin]]).isHolding = TRUE;
					((InteractiveObject*)[touches objectForKey:[sine origin]]).itemsHeld++;
				}
				[deadSines addObject:sine];																	//Reference the sine for removal from the active sine list (fast enumeration)
			}
		}
		
		float newB = cosine * c;																			//Recalculate the new position of the sine, at shorter to the target distance
		float newA = sqrt(c * c - newB * newB);
		if(end.y > begin.y)																					//If the sine is at lower position than the target reverse coordinates
			newA = -newA;
		
		CGPoint newPosition = {newB + end.x, newA + end.y};
		[sine setPosition:newPosition];
		
		angle *= 57.2958f;																					//Calculate the angle between the sine and target
		if(a < 0.0f)
			angle = 360 - angle;
		
		alpha = 0.0f;
		
		glLoadIdentity();
		glTranslatef(begin.x, begin.y, 0.0f);																//Move the coordinate system to the begin of the sine (the tip pointing to the target)
		glRotatef(angle, 0.0f, 0.0f, 1.0f);
		glTranslatef(-sineVertices[vertexIndex], 0.0f, 0.0f);												//The begining is at the tip. Compensate for this
		
		glBegin(GL_LINE_STRIP);
		for(int i = 0; i < (60 * [sine scale]); i +=2)														//Draw the sine only at it's length
		{
			glColor4f(color.r, color.g, color.b, alpha);
			alpha += 0.025f;
			glVertex2f(sineVertices[i + vertexIndex], sineVertices[i + vertexIndex + 1]);
		}
		glEnd();
	}
	
	for(sine in deadSines)																					//Remove dead sines
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
	
	for(uid in keys	)																						//Draw alive touches
	{
		if(!uid)
			continue;
		
		spot = [touches objectForKey:uid];																	//Get touch properties
		
		RGBA color = spot.color;
		
		if(spot.isHolding)																					//If the touch holds sines oscilate it's center at random distances each frame to shake it
		{
			spot.position.x += ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.0035);
			spot.position.y += ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.0035);
		}
		
		alpha = 0.8f;
		
		//Scale
		glLoadIdentity();
		glTranslated(spot.position.x, spot.position.y, 0.0);
		glScaled(spot.scale, spot.scale, 1.0);
		glTranslated(-spot.position.x, -spot.position.y, 0.0);

		[spot renderCircularTouchWithSectors:SECTORS_TOUCH withWhite:FALSE];
		
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
		
		if(spot.isScaling)																					//If the touch is scaling up
		{
			
			spot.scale += spot.delta;																		//Increment its radius
			if(spot.scale >= 1.0f)																			//If the radius is getting too big it should start getting smaller
			{
				if(spot.isNew)																				//If this is the first time the touch is at it's normal maximum radius
				{
					spot.isNew = FALSE;
					spot.delta = spot.delta = BASE_TOUCH_SCALE_DELTA / FRAMES;
				}
				spot.isScaling = !spot.isScaling;															//The touch should start scaling down
			}
		} else
		{
			spot.scale -= spot.delta;																		//Decrement the radius
			if (spot.scale < 0.7)																			//If the radius is too small start incrementing
			{
				spot.isScaling = !spot.isScaling;
			}
		}
	}
	
	keys = [dieingSpots allKeys];
	for(uid in keys)																						//Iterrate over spots with removed touches and suck them out
	{
		spot = [dieingSpots objectForKey:uid];
		
		alpha = 0.8f;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		glLoadIdentity();
		glTranslated(spot.position.x, spot.position.y, 0.0);
		glScaled(spot.scale, spot.scale, 1.0);
		glTranslated(-spot.position.x, -spot.position.y, 0.0);
		
		[spot renderCircularTouchWithSectors:SECTORS_TOUCH withWhite:FALSE];
		
		spot.scale -= spot.delta;
		if(spot.scale < spot.delta)
		{
			[deadSpots addObject:uid];																		//We can't modify a container while enumerating, so reference the dead object in another container
			continue;
		}
	}
	
	for(uid in deadSpots)																					//Iterrate the dead ripples and remove them forever
	{
		[dieingSpots removeObjectForKey:uid];
	}
	[deadSpots removeAllObjects];
	
	[lock unlock];
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
