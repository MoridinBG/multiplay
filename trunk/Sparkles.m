//
//  SparklesNonSim.m
//  Finger
//
//  Created by Mood on 8/11/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "Sparkles.h"


@implementation Sparkles

- (id) init
{
	[Logger logMessage:@"Init Sparkles" ofType:DEBUG_GENERAL];
	
	
	if(self = [super init])
	{
		radius = 0.025f;
		subStep = 0.039f / 8.0f;
		
		alphaStep = 0.8f / (radius / subStep);
		
		factory = [[SparklingFactory alloc] init];
		[factory start];
	}
	return self;
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
			[Logger logMessage:@"Processing Sparkles touch down event" ofType:DEBUG_TOUCH];
			
			LiteTouchInfo touch = {uniqueID, pos, TRUE};
			[factory setPosition:touch];
		} break;
		case TouchMove:
		{
			[Logger logMessage:@"Processing Sparkles touch move event" ofType:DEBUG_TOUCH_MOVE];
			
			if((pos.x == oldPos.x) && (pos.y == oldPos.y))
				return;
			
			LiteTouchInfo touch = {uniqueID, pos, FALSE};
			[factory setPosition:touch];
		} break;
		case TouchRelease:
		{
			[Logger logMessage:@"Processing Sparkles touch release event" ofType:DEBUG_TOUCH];
			
			[factory removePosition:uniqueID];
		} break;
	}
}

- (void) render
{
	sparkleGroups = [factory getPositions];

	keys = [sparkleGroups allKeys];
	for(uid in keys)
	{
		[Logger logMessage:@"Rendering a Sparkles fountain" ofType:DEBUG_RENDER];
		
		sparkleGroup = [sparkleGroups objectForKey:uid];

		RGBA color;
		[(NSValue*)[colors objectForKey:uid] getValue:&color];
		
		for(sparkle in sparkleGroup)
		{
			alpha = 0.8f;
			
			for(float subRadius = 0.001f; subRadius <= radius; subRadius += subStep)
			{
				glColor4f(color.r, color.g, color.b, alpha * sparkle.alpha);
				glBegin(GL_POLYGON);
				for(int i = 0; i <= (SECTORS_SPARKLE); i++) 
				{
					glVertex2f(subRadius * cosArray[i] + sparkle.position.x, 
							   subRadius * sinArray[i] + sparkle.position.y);
				}
				glEnd();
				
				alpha -= alphaStep;
			}
		}
	}
}
@end

