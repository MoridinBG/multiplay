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
	[Logger logMessage:@"Init ripples" ofType:DEBUG_GENERAL];
	
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
	
	if([event ignoreEvent])
		return;
	
	NSNumber *uid = event.uid;
	CGPoint pos = event.pos;
//	CGPoint oldPos = event.lastPos;
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Process ripple touch down event" ofType:DEBUG_TOUCH];
			
			InteractiveObject *ripple = [[InteractiveObject alloc] initWithPos:pos];
			[ripples setObject:ripple forKey:uid];
			
		} break;
		case TouchMove:
		{
			[Logger logMessage:@"Process ripple touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			[(InteractiveObject*)[ripples objectForKey:uid] setPosition:pos];
		} break;
		case TouchRelease:
		{
			[Logger logMessage:@"Process ripple touch release event" ofType:DEBUG_TOUCH];
			//Mark the ripple associated with this touch for suck away
			[dieingRipples setObject:[ripples objectForKey:uid] forKey:uid];
			[ripples removeObjectForKey:uid];
		} break;
	}
}

- (void) render
{
	float scale;
	float radius = 0.10;
	float angle;
	float delta;
	bool isScaling;
	bool isNew;
	
	CGPoint pos;
	NSNumber *uid;
	NSArray *keys = [ripples allKeys];
	InteractiveObject *ripple;
	
	if((![keys count]) && (![[dieingRipples allKeys] count]))
	{
		[colors removeAllObjects];
		return;
	}
	
	//Iterrate over living ripples
	for(uid in keys)
	{
		[Logger logMessage:[NSString stringWithFormat:@"Rendering ripple %d", [uid integerValue]] ofType:DEBUG_RENDER];
		
		ripple = [ripples objectForKey:uid];
		scale = ripple.scale;;
		pos = ripple.position;
		angle = ripple.angle;
		delta = ripple.delta;
		isScaling = ripple.isScaling;
		isNew = ripple.isNew;
		
		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		

		glLoadIdentity();
		glTranslated(pos.x, pos.y, 0.0f);
		glScaled(scale, scale, 0.0f);
		glRotated(angle, 0.0f, 0.0f, 1.0f);
		glTranslated(-pos.x, -pos.y, 0.0f);
		[ripple setAngle:(angle + 1.0f)];
		
		glBegin(GL_TRIANGLE_FAN);
		//Set the color for the center
		glColor3f(color.r, color.g, color.b);
		glVertex2f(pos.x, pos.y);
		for(int i = 0; i <= SECTORS_RIPPLE;i++) 
		{
			//Draw bigger ripple in one color
			glColor3f(color.r, color.g, color.b);
			glVertex2f(radius * cosArray[i] + pos.x, 
					   radius * sinArray[i] + pos.y);

			//And smaller one in different color
			glColor3f(color.b, color.r, color.g);
			glVertex2f(radius / 1.5 * cosArray[i] + pos.x, 
					   radius / 1.5 * sinArray[i] + pos.y);
		}
		glEnd();

		if(isScaling)																//Is the ripple getting bigger?
		{
			
			scale += delta;															//Increment its radius
			if(scale > 1)															//If the radius is getting too big we should start getting smaller
			{
				if(isNew)													//If the ripple has gotten so big for the first time decrement the scaling step
				{
					[ripple setIsNew:FALSE];
					[ripple setDelta:0.011];
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

		angle += 2.0f;
		
		[ripple setParameters:pos scale:scale angle:angle isScaling:isScaling];		//Update current ripple's parameters
	}
	
	keys = [dieingRipples allKeys];													//Iterrate over ripples with removed touches and suck them out
	for(uid in keys)
	{
		ripple = [dieingRipples objectForKey:uid];
		scale = [ripple scale];
		pos = [ripple position];
		
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
		for(int i = 0; i <= SECTORS_RIPPLE;i++) 
		{
			//Draw bigger ripple in one color
			glColor3f(color.r, color.g, color.b);
			glVertex2f(radius * cosArray[i] + pos.x, 
					   radius * sinArray[i] + pos.y);
			
			//And smaller one in different color
			glColor3f(color.b, color.r, color.g);
			glVertex2f(radius / 1.5 * cosArray[i] + pos.x, 
					   radius / 1.5 * sinArray[i] + pos.y);
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
