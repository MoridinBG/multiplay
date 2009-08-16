//
//  Ripples.m
//  Finger
//
//  Created by Ivan Dilchovski on 7/31/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "Ripples.h"


@implementation Ripples
- (id) init
{
	if(DEBUG_GENERAL)
		NSLog(@"Init ripples");
	
	if(self = [super init])
	{
		ripples = [[NSMutableDictionary alloc] initWithCapacity:100];
		dieingRipples = [[NSMutableDictionary alloc] init];
		deadRipples = [[NSMutableArray alloc] init];
		
		rot = 0;
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
	[super processTouches:event];
	NSNumber *uid = event.uid;
	CGPoint pos = event.pos;
//	CGPoint oldPos = event.lastPos;
	switch (event.type) 
	{
		case TouchDown:
		{
			if(DEBUG_TOUCH)
				NSLog(@"Process ripple touch down event");
			
			TouchSpot *ripple = [[TouchSpot alloc] initWithPos:pos];
			[ripples setObject:ripple forKey:uid];
			
		} break;
		case TouchMove:
		{
			[(TouchSpot*)[ripples objectForKey:uid] setPosition:pos];
		} break;
		case TouchRelease:
		{
			//Mark the ripple associated with this touch for suck away
			[dieingRipples setObject:[ripples objectForKey:uid] forKey:uid];
			[ripples removeObjectForKey:uid];
		} break;
	}
}

- (void) render
{
	float scale;
	float radius = 0.25;
	float angle;
	float delta;
	bool isScaling;
	bool isNew;
	
	CGPoint pos;
	NSNumber *uid;
	NSArray *keys = [ripples allKeys];
	TouchSpot *ripple;
	
	if((![keys count]) && (![[dieingRipples allKeys] count]))
	{
		[colors removeAllObjects];
		return;
	}
	
	//Iterrate over living ripples
	for(uid in keys)
	{
		if(DEBUG_RENDER)
			NSLog(@"Rendering ripple %d", [uid integerValue]);
		
		ripple = [ripples objectForKey:uid];
		scale = [ripple scale];
		pos = [ripple position];
		angle = [ripple angle];
		delta = [ripple delta];
		isScaling = [ripple isScaling];
		isNew = [ripple isNew];
		
		NSArray *color = [colors objectForKey:uid];

		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0f);
		glScaled(scale, scale, 0.0f);
		glRotated(angle, 0.0f, 0.0f, 1.0f);
		glTranslated(-pos.x, -pos.y, 0.0f);
		[ripple setAngle:(angle + 1.0f)];
		
		glBegin(GL_TRIANGLE_FAN);
		//Set the color for the center
		glColor3f([[color objectAtIndex:0] floatValue], [[color objectAtIndex:1] floatValue], [[color objectAtIndex:2] floatValue]);
		glVertex2f(pos.x, pos.y);
		for(int i = 0; i <= SECTORS_RIPPLE;i++) 
		{
			//Draw bigger ripple in one color
			glColor3f([[color objectAtIndex:0] floatValue], [[color objectAtIndex:1] floatValue], [[color objectAtIndex:2] floatValue]);
			glVertex2f(radius * cosArray[i] + pos.x, 
					   radius * sinArray[i] + pos.y);

			//And smaller one in different color
			glColor3f([[color objectAtIndex:2] floatValue], [[color objectAtIndex:0] floatValue], [[color objectAtIndex:1] floatValue]);
			glVertex2f(radius / 2 * cosArray[i] + pos.x, 
					   radius / 2 * sinArray[i] + pos.y);
		}
		glEnd();

		if(isScaling)																//Is the ripple getting bigger?
		{
			
			scale += delta;															//Increment its radius
			if(scale > 1)															//If the radius is getting too big we should start getting smaller
			{
				if([ripple isNew])													//If the ripple has gotten so big for the first time decrement the scaling step
				{
					[ripple setIsNew:FALSE];
					[ripple setDelta:0.008];
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

		angle += 1.7f;
		
		[ripple setParameters:pos scale:scale angle:angle isScaling:isScaling];		//Update current ripple's parameters
	}
	
	keys = [dieingRipples allKeys];													//Iterrate over ripples with removed touches and suck them out
	for(uid in keys)
	{
		ripple = [dieingRipples objectForKey:uid];
		scale = [ripple scale];
		pos = [ripple position];
		
		NSArray *color = [colors objectForKey:uid];
		
		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0f);
		glScaled(scale, scale, 0.0f);
		glTranslated(-pos.x, -pos.y, 0.0f);
		
		glBegin(GL_TRIANGLE_FAN);
		//Set the color for the center
		glColor3f([[color objectAtIndex:0] floatValue], [[color objectAtIndex:1] floatValue], [[color objectAtIndex:2] floatValue]);
		glVertex2f(pos.x, pos.y);
		for(int i = 0; i <= SECTORS_RIPPLE;i++) 
		{
			//Draw bigger ripple in one color
			glColor3f([[color objectAtIndex:0] floatValue], [[color objectAtIndex:1] floatValue], [[color objectAtIndex:2] floatValue]);
			glVertex2f(radius * cosArray[i] + pos.x, 
					   radius * sinArray[i] + pos.y);
			
			//And smaller one in different color
			glColor3f([[color objectAtIndex:2] floatValue], [[color objectAtIndex:0] floatValue], [[color objectAtIndex:1] floatValue]);
			glVertex2f(radius / 2 * cosArray[i] + pos.x, 
					   radius / 2 * sinArray[i] + pos.y);
		}
		glEnd();
		
		scale -= 0.1f;
		if(scale <= 0.1f)
		{
			[deadRipples addObject:uid];											//We can't modify a container while enumerating, so reference the dead object in another container
			continue;
		}
		[ripple setScale:scale];
	}
	
	for(uid in deadRipples)															//Iterrate the dead ripples and remove them forever
	{
		[dieingRipples removeObjectForKey:uid];
	}
	[deadRipples removeAllObjects];
}
@end
