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
	if(DEBUG_GENERAL)
		NSLog(@"Init Sparkles");
	
	
	if(self = [super init])
	{
		radius = 0.040f;
		subStep = 0.039f / 4.0f;
		
		alphaStep = 0.8f / (radius / subStep);
		
		factory = [[SparklingFactory alloc] init];
		[factory start];
	}
	return self;
}

- (void) processTouches:(TouchEvent*)event
{
	[super processTouches:event];
	NSNumber *uid = event.uid;
	CGPoint pos = event.pos;
	CGPoint oldPos = event.lastPos;
	switch (event.type) 
	{
		case TouchDown:
		{
			if(DEBUG_TOUCH)
				NSLog(@"Process sparkle touch down event");
			
			LiteTouchInfo touch = {uid, pos};
			[factory setPosition:touch];
			
			NSMutableArray *color = [[NSMutableArray alloc] initWithCapacity:3];
			[color addObject:[NSNumber numberWithFloat:(((float)(arc4random() % 1000)) / 1000)]];
			[color addObject:[NSNumber numberWithFloat:(((float)(arc4random() % 1000)) / 1000)]];
			[color addObject:[NSNumber numberWithFloat:(((float)(arc4random() % 1000)) / 1000)]];
			[colors setObject:color forKey:uid];
		} break;
		case TouchMove:
		{
			if(DEBUG_TOUCH_MOVE)
				NSLog(@"Process sparkle touch move event");
			
			if((pos.x == oldPos.x) && (pos.y == oldPos.y))
				return;
			
			LiteTouchInfo touch = {uid, pos};
			[factory setPosition:touch];
		} break;
		case TouchRelease:
		{
			if(DEBUG_TOUCH)
				NSLog(@"Process sparkle touch release event");
			
			[factory removePosition:uid];
		} break;
	}
}

- (void) render
{
	sparkleGroups = [factory getPositions];
	keys = [sparkleGroups allKeys];
	if(![keys count])
	{
		[colors removeAllObjects];
		return;
	}
	
	for(uid in keys)
	{
		if(DEBUG_RENDER)
			NSLog(@"Rendering new sparkles fountain");
		
		sparkleGroup = [sparkleGroups objectForKey:uid];
		NSArray *color = [colors objectForKey:uid];
		
		for(sparkleWrapper in sparkleGroup)
		{
			struct Sparkle sparkle;
			[sparkleWrapper getValue:&sparkle];
			
			alpha = 0.8f;
			
			for(float subRadius = 0.001f; subRadius <= radius; subRadius += subStep)
			{
				glColor4f([[color objectAtIndex:0] floatValue], [[color objectAtIndex:1] floatValue], [[color objectAtIndex:2] floatValue], alpha * sparkle.alpha);
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

