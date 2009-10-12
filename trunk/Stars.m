//
//  Stars.m
//  Finger
//
//  Created by Ivan Dilchovski on 7/31/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "Stars.h"


@implementation Stars
- (id) init
{
	if(self = [super init])
	{
		[Logger logMessage:@"Init stars" ofType:DEBUG_GENERAL];
		
		dieingStars = [[NSMutableDictionary alloc] init];
		deadStars = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) finalize
{
	free(cosArray);
	free(cosOffsetArray);
	
	free(sinArray);
	free(sinOffsetArray);
	
	[super finalize];
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
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Processing Stars touch down event" ofType:DEBUG_TOUCH];
			
			InteractiveObject *star = [[InteractiveObject alloc] initWithPos:pos];
			[touches setObject:star forKey:uniqueID];
			
		} break;
		case TouchMove:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing Stars touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			[(InteractiveObject*)[touches objectForKey:uniqueID] setPosition:pos];
		} break;
		case TouchRelease:
		{
			if(![touches objectForKey:uniqueID])
			{
				[lock unlock];
				return;
			}
			
			[Logger logMessage:@"Processing Stars touch release event" ofType:DEBUG_TOUCH];
			
			//Mark the star associated with this touch for sucktion
			[dieingStars setObject:[touches objectForKey:uniqueID] forKey:uniqueID];
			[touches removeObjectForKey:uniqueID];
		} break;
	}
	[lock unlock];
}

- (void) render
{
	[lock lock];
	float scale;
	float radius = 0.10;
	float angle;
	float rotateDelta;
	float delta;
	bool isScaling;
	bool isNew;
	bool rotateLeft;
	
	CGPoint pos;
	NSNumber *uid;
	NSArray *keys = [touches allKeys];
	InteractiveObject *star;
	
	if((![keys count]) && (![[dieingStars allKeys] count]))
	{
		[colors removeAllObjects];
		[lock unlock];
		return;
	}
	
	//Iterrate over living stars
	for(uid in keys)
	{
		if(!uid)
			continue;
		
		[Logger logMessage:[NSString stringWithFormat:@"Rendering star %d", [uid integerValue]] ofType:DEBUG_RENDER];
		
		star = [touches objectForKey:uid];
		
		scale = star.scale;;
		pos = star.position;
		angle = star.angle;
		delta = star.delta;
		isScaling = star.isScaling;
		isNew = star.isNew;
		rotateLeft = star.rotateLeft;
		rotateDelta = star.rotateDelta;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		

		glLoadIdentity();															//Draw the current star with it's scale and rotation factors
		glTranslated(pos.x, pos.y, 0.0f);
		glScaled(scale, scale, 0.0f);
		glRotated(angle, 0.0f, 0.0f, 1.0f);
		glTranslated(-pos.x, -pos.y, 0.0f);
		
		glBegin(GL_TRIANGLE_FAN);													//Start drawing the star
		glColor3f(color.r, color.g, color.b);										//Set the color for the center
		glVertex2f(pos.x, pos.y);
		for(int i = 0; i <= SECTORS_STARS; i++) 
		{
			//Draw bigger star in one color
			glColor3f(color.r, color.g, color.b);
			glVertex2f(radius * cosArray[i] + pos.x, 
					   radius * sinArray[i] + pos.y);

			//And smaller one in different color
			glColor3f(color.b, color.r, color.g);
			glVertex2f(radius / 1.5 * cosArray[i] + pos.x, 
					   radius / 1.5 * sinArray[i] + pos.y);
		}
		glEnd();

		if(isScaling)																//Is the star getting bigger?
		{
			
			scale += delta;															//Increment its radius
			if(scale > 1)															//If the radius is getting too big we should start getting smaller
			{
				if(isNew)															//If the star has gotten so big for the first time decrement the scaling step
				{
					[star setIsNew:FALSE];
					[star setDelta:0.02];
				}
				isScaling = !isScaling;												//Not scaling anymore
			}
		} else																		//The star is getting smaller
		{
			scale -= delta;															//Decrement the radius
			if (scale < 0.65)														//If the radius is too small start incrementing
			{
				isScaling = !isScaling;												//Scaling again
			}
		}

		if(rotateLeft)																//The rotation angle for the star is incremented when rotating left and decremented otherwise
		{
			angle += rotateDelta;
			
			if(star.angle >= 360)													//Avoid extremely big angles for long living stars
				star.angle -= 360;
		}
		else
		{
			angle -= rotateDelta;
			
			if(star.angle <= 360)
				star.angle += 360;
		}
		
																					//Update current star's parameters
		star.position = pos;
		star.scale = scale;
		star.angle = angle;
		star.isScaling = isScaling;
	}
	
	keys = [dieingStars allKeys];													//Iterrate over stars with removed touche and suck them out
	for(uid in keys)
	{
		[Logger logMessage:[NSString stringWithFormat:@"Rendering dead star %d", [uid integerValue]] ofType:DEBUG_RENDER];
		
		star = [dieingStars objectForKey:uid];
		scale = [star scale];
		pos = [star position];
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0f);
		glScaled(scale, scale, 0.0f);
		glTranslated(-pos.x, -pos.y, 0.0f);
		
		glBegin(GL_TRIANGLE_FAN);
		//Set the color for the center
		glColor3f(color.r, color.g, color.b);
		glVertex2f(pos.x, pos.y);
		for(int i = 0; i <= SECTORS_STARS;i++) 
		{
			//Draw bigger star in one color
			glColor3f(color.r, color.g, color.b);
			glVertex2f(radius * cosArray[i] + pos.x, 
					   radius * sinArray[i] + pos.y);
			
			//And smaller one in different color
			glColor3f(color.b, color.r, color.g);
			glVertex2f(radius / 1.5 * cosArray[i] + pos.x, 
					   radius / 1.5 * sinArray[i] + pos.y);
		}
		glEnd();
		
		scale -= 0.15f;																//Start scaling down the star
		if(scale <= 0.1f)															//When the scale factor is too little the star is finally dead
		{
			[deadStars addObject:uid];											//We can't modify a container while enumerating, so reference the dead object in another container
			continue;
		}
		[star setScale:scale];
	}
	
	for(uid in deadStars)															//Iterrate the dead stars and remove them forever
	{
		[dieingStars removeObjectForKey:uid];
	}
	[deadStars removeAllObjects];
	
	[lock unlock];
}
@end
