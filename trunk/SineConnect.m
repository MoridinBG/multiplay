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
		
		spots = [[NSMutableDictionary alloc] initWithCapacity:100];
		dieingSpots = [[NSMutableDictionary alloc] init];
		deadSpots = [[NSMutableArray alloc] init];
		
		for(unsigned int i = 0; i <= 15; i++)
			for(unsigned int j = 0; j <= 9; j++)
				sectors[i][j] = [[NSMutableArray alloc] init];
		
		walker = [[SineWalker alloc] init];
		[walker start];
	}
	return self;
}

- (NSMutableArray*) collectNeighboursAtX:(int) x Y:(int)y
{
	NSMutableArray *neighbours = [[NSMutableArray alloc] init];
	
	for(int xDelta = -2; xDelta <= 2; xDelta++)
		for(int yDelta = -2; yDelta <=2; yDelta++)
		{
			int tmpX = x + xDelta;
			int tmpY = y + yDelta;
			if((tmpX >= 0) && (tmpX <=15) && (tmpY >= 0) && (tmpY <= 9))
			{
				if([sectors[tmpX][tmpY] count])
					[neighbours addObjectsFromArray:sectors[tmpX][tmpY]];
			}
		}
	
	return neighbours;
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
			[Logger logMessage:@"Process sine touch down event" ofType:DEBUG_TOUCH];

			if((pos.x < -1.60f) || (pos.x > 1.60f) || (pos.y < -1.0f) || (pos.y > 1.0f))
			{
				[Logger logMessage:@"Touch out of range" ofType:DEBUG_GENERAL];
				return;
			}
			
			ConnectableInteractor *spot = [[ConnectableInteractor alloc] initWithPos:pos];
			[spot setDelta:0.1];
			[spots setObject:spot forKey:uniqueID];
			
			int x = pos.x * 5 + 8;
			int y = pos.y * 5 + 5;
			
			[Logger logMessage:[NSString stringWithFormat:@"Position: %d, %d", x, y] ofType:DEBUG_GENERAL];
			[Logger logMessage:[NSString stringWithFormat:@"Touches in the same sector: %d", [sectors[x][y] count]] ofType:DEBUG_GENERAL];
			
			NSMutableArray *neighbours = [self collectNeighboursAtX:x Y:y];
			
			if(![neighbours count])
			{
				[sectors[x][y] addObject:uniqueID];
				return;
			}
			
			[Logger logMessage:[NSString stringWithFormat:@"Neighbours: %d", [neighbours count]] ofType:DEBUG_GENERAL];
			
			ConnectableInteractor *sine = [[ConnectableInteractor alloc] init];
			NSNumber *targetUid = [neighbours objectAtIndex:((arc4random() % [neighbours count]))];
			CGPoint targetPos;
			ConnectableInteractor *target = [spots objectForKey:targetUid];
			targetPos = [target position];
			[sine setTarget:targetUid withPosition:targetPos];
			
			[spot addConnectee:((LiteTouchInfo)[sine target]).uid];													//Tell our new spot that it has a connectee
			[[spots objectForKey:[sine target].uid] addConnectee:uniqueID];							//Tell the connectee the news about the new spot
			
			[walker addSine:sine withUid:targetUid];
			
			[sectors[x][y] addObject:uniqueID];
		} break;
		case TouchMove:
		{
			if(DEBUG_TOUCH_MOVE)
				NSLog(@"Process sine touch move event");
			
			[(ConnectableInteractor*)[spots objectForKey:uniqueID] setPosition:pos];
			
			int x = pos.x * 5 + 8;
			int y = pos.y * 5 + 5;
			
			int oldX = oldPos.x * 5 + 8;
			int oldY = oldPos.y * 5 + 5;
			
			if((x != oldX) || (y != oldY))
			{
				[sectors[oldX][oldY] removeObject:uniqueID];
				[sectors[x][y] addObject:uniqueID];
			}
		} break;
		case TouchRelease:
		{
			if(DEBUG_TOUCH)
				NSLog(@"Process sine touch release event");
			
			int x = pos.x * 5 + 8;																//Translate X coordinates to array location
			int y = pos.y * 5 + 5;																//Same for Y coordinates
			
			[sectors[x][y] removeObject:uniqueID];												//Remove the touch from this location
			
//			if()									//If the spot shares sines
			
			[dieingSpots setObject:[spots objectForKey:uniqueID] forKey:uniqueID];
			[spots removeObjectForKey:uniqueID];
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
	
	sines = [walker getSines];
	keys = [sines allKeys];															//Draw sines
	glLineWidth(2);
	for(uid in keys)
	{
//		NSArray *color = [colors objectForKey:uid];
		
		CGPoint begin;
		begin = [(InteractiveObject*)[spots objectForKey:uid] position];
		CGPoint end;
		end = [(ConnectableInteractor*)[spots objectForKey:[walker targetForSine:uid]] position];
		
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
		
//		glColor3f([[color objectAtIndex:0] floatValue], [[color objectAtIndex:1] floatValue], [[color objectAtIndex:2] floatValue]);
		glColor3f(1.0, 1.0, 1.0);
		glBegin(GL_LINE_STRIP);
		for(float i = f; i <= (f + (c * 10.0f)); i += 0.1f)
		{
			glVertex2f(i / 10, sin(i * 360 * (PI/180.0f)) / 24);
		}
		glEnd();
	}
	
	//Debug sectors network
/*	glLineWidth(1);
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
	glLineWidth(4);*/
	
	keys = [spots allKeys];
	if((![keys count]) && (![[dieingSpots allKeys] count]))
	{
		[colors removeAllObjects];
		return;
	}
	
	for(uid in keys	)																//Draw alive spots
	{
		spot = [spots objectForKey:uid];
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
@end
