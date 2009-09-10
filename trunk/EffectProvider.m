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
			sectors = SECTORS_RIPPLE;
		}
		else if(([self isKindOfClass:[SineConnect class]]) || ([self isKindOfClass:[LineConnect class]]))
		{
			physicsThread = [[b2Physics alloc] init];
			sectors = SECTORS_TOUCH;
		}
		
		multiplexor = [[TuioMultiplexor alloc] initWithListeners:2];
		[multiplexor setProvider:self];
		
		listeners = [[NSMutableArray alloc] init];
		
		TuioListener *listener = [[TuioListener alloc] init];
		[listener setMultiplexor:multiplexor];
		[listeners addObject:listener];
		
		
		colors = [[NSMutableDictionary alloc] initWithCapacity:100];
		touches = [[NSMutableDictionary alloc] initWithCapacity:100];
		
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
	CGPoint pos = [event pos];
	if((pos.x < 0) || (pos.x > 1.60f) || (pos.y < 0) || (pos.y > 1.0f))
	{
		[Logger logMessage:@"Touch out of range" ofType:DEBUG_GENERAL];
		return;
	}
	switch (event.type) 
	{
		case TouchDown:
		{
			[Logger logMessage:@"Process ancestor touch down event" ofType:DEBUG_TOUCH];
			
			RGBA colorStruct = {(((float)(arc4random() % 1000)) / 1000), (((float)(arc4random() % 1000)) / 1000), (((float)(arc4random() % 1000)) / 1000), 1.0f};
			NSValue *color = [NSValue value:&colorStruct withObjCType:@encode(RGBA)];

			[colors setObject:color forKey:event.uid];
		} break;
			
		case TouchMove:
		{
//			if((pow(event.pos.x - event.lastPos.x, 2) < 0.05) && (pow(event.pos.y - event.lastPos.y, 2) < 0.05))
//				[event setIgnoreEvent:TRUE];

		} break;
			
		case TouchRelease:
		{

		} break;
	}
}
- (void) setDimensions:(NSSize) dimensions_
{
	dimensions = dimensions_;
	[multiplexor setDimensions:dimensions];
}
@end
