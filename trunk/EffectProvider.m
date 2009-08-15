//
//  MultitouchScene.m
//  Finger
//
//  Created by Ivan Dilchovski on 7/16/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "EffectProvider.h"

@implementation EffectProvider

- (id) init
{
	if (self = [super init])
	{
		int sectors;
		if([self isKindOfClass:[Sparkles class]])
		{
			sectors = SECTORS_SPARKLE;
		}
		else if([self isKindOfClass:[Ripples class]])
		{
			physicsThread = [[Physics alloc] init];		
			sectors = SECTORS_RIPPLE;
		}
		else if([self isKindOfClass:[SineConnect class]])
		{
			sectors = SECTORS_TOUCH;
		}
		
		listener = [[TuioListener alloc] init];
		[listener setProvider:self];
		
		colors = [[NSMutableDictionary alloc] initWithCapacity:100];
		
		cosArray = malloc(sectors * sizeof(float));
		cosOffsetArray = malloc(sectors * sizeof(float));
		
		sinArray = malloc(sectors * sizeof(float));
		sinOffsetArray = malloc(sectors * sizeof(float));		
		
		for(int i = 0; i <= sectors; i++)
		{
			cosArray[i] = cos(i * 2 * PI / sectors);
			cosOffsetArray[i] = cos(i * 2 * PI / sectors + 0.2);
			
			sinArray[i] = sin(i * 2 * PI / sectors);
			sinOffsetArray[i] = sin(i * 2 * PI / sectors + 0.2);
		}
	}
	return self;
}

- (void) processTouches:(TouchEvent*)event
{
	switch (event.type) 
	{
		case TouchDown:
		{
			if(DEBUG_TOUCH)
				NSLog(@"Process ancestor touch down event");
			
			NSMutableArray *color = [[NSMutableArray alloc] initWithCapacity:3];
			[color addObject:[NSNumber numberWithFloat:(((float)(arc4random() % 1000)) / 1000)]];
			[color addObject:[NSNumber numberWithFloat:(((float)(arc4random() % 1000)) / 1000)]];
			[color addObject:[NSNumber numberWithFloat:(((float)(arc4random() % 1000)) / 1000)]];
			[colors setObject:color forKey:event.uid];
		} break;
			
		case TouchMove:
		{

		} break;
			
		case TouchRelease:
		{

		} break;
	}
}
- (void) setDimensions:(NSSize) dimensions_
{
	dimensions = dimensions_;
	[listener setDimensions:dimensions];
}
@end
