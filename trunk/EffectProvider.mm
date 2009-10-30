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
		else if(([self isKindOfClass:[Stars class]]) || ([self isKindOfClass:[Ripples class]]))
		{
			sectors = SECTORS_STARS;
		}
		else if(([self isKindOfClass:[SineConnect class]]) || ([self isKindOfClass:[LineConnect class]]) || ([self isKindOfClass:[InteractiveImages class]]))
		{
			sectors = SECTORS_TOUCH;
		}
		else if(([self isKindOfClass:[TextCircle class]]) || ([self isKindOfClass:[Ripples class]]))
		{
			sectors = 0;
		}
		
		multiplexor = [[TuioMultiplexor alloc] init];
		[multiplexor setProvider:self];
		
		listener = new TUIOppListener(3333);
		listener->setMultiplexor(multiplexor);
		
		listener2 = new TUIOppListener(3334);
		listener2->setMultiplexor(multiplexor);
		
		colors = [[NSMutableDictionary alloc] initWithCapacity:100];
		touches = [[NSMutableDictionary alloc] initWithCapacity:100];
		activeUIDs = [[NSMutableArray alloc] initWithCapacity:100];
		
		cosArray = (float*) malloc(sectors * sizeof(float));
		cosOffsetArray = (float*) malloc(sectors * sizeof(float));
		
		sinArray = (float*) malloc(sectors * sizeof(float));
		sinOffsetArray = (float*) malloc(sectors * sizeof(float));		
		
		for(int i = 0; i <= sectors; i++)
		{
			cosArray[i] = cos(i * 2 * PI / sectors);
			cosOffsetArray[i] = cos(i * 2 * PI / sectors + 0.2);
			
			sinArray[i] = sin(i * 2 * PI / sectors);
			sinOffsetArray[i] = sin(i * 2 * PI / sectors + 0.2);
		}
		
		lock = [[NSRecursiveLock alloc] init];
		
	}
	return self;
}

- (void) processTouches:(TouchEvent*)event
{
	[lock lock];
//	CGPoint pos = [event pos];
	switch (event.type) 
	{
		case TouchDown:
		{	
			RGBA colorStruct = {(((float)(arc4random() % 1000)) / 1000), (((float)(arc4random() % 1000)) / 1000), (((float)(arc4random() % 1000)) / 1000), 1.0f};
			NSValue *color = [NSValue value:&colorStruct withObjCType:@encode(RGBA)];
			
			[activeUIDs addObject:event.uid];

			[colors setObject:color forKey:event.uid];
		} break;
			
		case TouchMove:
		{
//			if((pow(event.pos.x - event.lastPos.x, 2) < 0.05) && (pow(event.pos.y - event.lastPos.y, 2) < 0.05))
//				[event setIgnoreEvent:TRUE];

		} break;
			
		case TouchRelease:
		{
			[activeUIDs removeObject:event.uid];
		} break;
	}
	[lock unlock];
}
- (void) setDimensions:(CGSize) dimensions_
{
	dimensions = dimensions_;
	[multiplexor setDimensions:dimensions];
	
	dimensions.width = dimensions.width / dimensions.height;
	dimensions.height = 1.f;
	
	if(([self isKindOfClass:[SineConnect class]]) || ([self isKindOfClass:[LineConnect class]]))
	{
		physics = [[b2Physics alloc] initWithDimensions:dimensions withFrame:FALSE];
	}
	else if([self isKindOfClass:[InteractiveImages class]])
	{
		physics = [[b2Physics alloc] initWithDimensions:dimensions withFrame:TRUE];
	}
	
	dimensions = dimensions_;
}
@end
