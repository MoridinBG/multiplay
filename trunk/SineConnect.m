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
		f = 0.0f;
		
		radius = 0.19f;
		subStep = 0.039f / 4.0f;
		
		alphaStep = 0.8f / (radius / subStep);
		
		spots = [[NSMutableDictionary alloc] initWithCapacity:100];
		dieingSpots = [[NSMutableDictionary alloc] init];
		deadSpots = [[NSMutableArray alloc] init];
		sines = [[NSMutableDictionary alloc] init];
		
		for(unsigned int i = 0; i < 15; i++)
			for(unsigned int j = 0; j < 9; j++);
			//	sectors[i][j] = [[NSMutableArray alloc] init];
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
			if(DEBUG_TOUCH)
				NSLog(@"Process sine touch down event");

			TouchSpot *spot = [[TouchSpot alloc] initWithPos:pos];
			[spot setDelta:0.1];
			[spots setObject:spot forKey:uniqueID];
			
			if((pos.x < -1.60f) || (pos.x > 1.60f) || (pos.y < -1.0f) || (pos.y > 1.0f))
				return;
			
			int x = pos.x * 5 + 8;
			int y = pos.y * 5 + 5;
			[sectors[x][y] addObject:uniqueID];
			
			if(([spots count] / 3) > [sines count])
			{
				NSArray *keys = [spots allKeys];
				CGPoint position = ((TouchSpot*)[spots objectForKey:[keys objectAtIndex:(arc4random() % [keys count])]]).position;
				TouchSpot *sine = [[TouchSpot alloc] initWithPos:position];
				[sines setObject:sine forKey:uniqueID];
			}
		} break;
		case TouchMove:
		{
			if(DEBUG_TOUCH_MOVE)
				NSLog(@"Process sine touch move event");
			
			[(TouchSpot*)[spots objectForKey:uniqueID] setPosition:pos];
			
			int x = pos.x * 5 + 8;
			int y = pos.y * 5 + 5;
			
			int oldX = oldPos.x * 5 + 8;
			int oldY = oldPos.y * 5 + 5;
			
			if((x != oldX) || (y != oldY))
			{
				[sectors[oldX][oldY] removeObject:uid];
				[sectors[x][y] addObject:uid];
			}
		} break;
		case TouchRelease:
		{
			if(DEBUG_TOUCH)
				NSLog(@"Process sine touch release event");
			
			int x = pos.x * 5 + 8;
			int y = pos.y * 5 + 5;
			
			[sectors[x][y] removeObject:uid];
			
			[dieingSpots setObject:[spots objectForKey:uniqueID] forKey:uniqueID];
			[spots removeObjectForKey:uniqueID];
		} break;
	}
}

- (void) render
{
	TouchSpot *spot;
	float scale;
	CGPoint pos;
	float delta;
	bool isScaling;
	bool isNew;
	
	keys = [spots allKeys];
	
	if((![keys count]) && (![[dieingSpots allKeys] count]))
	{
		[colors removeAllObjects];
		return;
	}
	
	glLoadIdentity();
//	glRotatef(angle, 0.0f, 0.0f, 1.0f);
//	glTranslatef(-(f/10), 0.0f, 0.0f);
	
	glColor3f(1.0f, 1.0f, 1.0f);
	glBegin(GL_LINE_STRIP);
	for(float i = f; i <= (f+ 10.0f); i += 0.1f)
	{
		glVertex2f(i / 10, sin(i * 360 * (PI/180.0f)) / 24);
	}
	glEnd();
	
	//Draw alive spots
	for(uid in keys	)
	{
		spot = [spots objectForKey:uid];
		scale = [spot scale];
		pos = [spot position];
		delta = [spot delta];
		isScaling = [spot isScaling];
		isNew = [spot isNew];
		
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
			[deadSpots addObject:uid];		//We can't modify a container while enumerating, so reference the dead object in another container
			continue;
		}
		[spot setScale:scale];
	}
	
	//Iterrate the dead ripples and remove them forever
	for(uid in deadSpots)
	{
		[dieingSpots removeObjectForKey:uid];
	}
	[deadSpots removeAllObjects];
		
/*	float a = pos.y;
	float b = pos.x;
	float c = sqrt(a*a + b*b);
	float angle = acos(b/c);
	
	angle *=57.2958f;
	if(a < 0.0f)
		angle = 360 - angle;
	
	alpha = 0.8f;
	
	glLoadIdentity();
	glRotatef(angle, 0.0f, 0.0f, 1.0f);
	//glTranslatef(-1.6f, 0.0f, 0.0f);
	glTranslatef(-(f/10), 0.0f, 0.0f);
	
	glColor3f(1.0f, 1.0f, 1.0f);
	glBegin(GL_LINE_STRIP);
	for(float i = f; i <= (f + (c * 10.0f)); i += 0.1f)
	{
		glVertex2f(i / 10, sin(i * 360 * (PI/180.0f)) / 24);
	}
	glEnd(); */
	
	f += 0.1f;
	if(f == 1.0f)
		f = 0.0f; 
}
@end
