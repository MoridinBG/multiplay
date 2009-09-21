//
//  InteractiveObject.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import "InteractiveObject.h"


@implementation InteractiveObject

@synthesize scale;
@synthesize angle;
@synthesize position;
@synthesize isScaling;
@synthesize isNew;
@synthesize delta;
@synthesize physicsData;
@synthesize color;
@synthesize isHolding;
@synthesize rotateDelta;
@synthesize rotateLeft;
@synthesize direction;

- (id) initWithPos:(CGPoint) pos
{
	if(self = [self init])
	{
		position = pos;
	}
	return self;
}

- (id) init
{
	if(self = [super init])
	{
		scale = 0.01f;
		isScaling = TRUE;
		isNew = TRUE;
		delta = 0.13;
		
		angle = 0.0f;
		rotateDelta = 0.1;
		if((arc4random() % 100) > 50)
			rotateLeft = TRUE;
		else
			rotateLeft = FALSE;
		
		neighbours = [[NSMutableArray alloc] init];
		connectedNeighbours = [[NSMutableDictionary alloc] initWithCapacity:100];
		
	}
	return self;
}

- (void) setParameters:(CGPoint) position_ scale:(float) scale_ angle:(float) angle_ isScaling:(bool) isScaling_
{
	position = position_;
	scale = scale_;
	angle = angle_;
	isScaling = isScaling_;
}

- (void) addNeighbour:(NSNumber*) uid
{
	[neighbours addObject:uid];
}

- (void) removeNeighbour:(NSNumber*) uid
{
	[neighbours removeObject:uid];
}

- (NSArray*) getNeighbours
{
	return neighbours;
}

- (bool) hasNeighbour:(NSNumber*) uid
{
	return [neighbours containsObject:uid];
}

- (int) neighboursCount
{
	return [neighbours count];
}

- (void) addNeighbour:(NSNumber*) uid withConnection:(TargettingInteractor*) connection
{
	[connectedNeighbours setObject:connection forKey:uid];
}

- (TargettingInteractor*) removeConnectedNeighbour:(NSNumber*) uid
{
	TargettingInteractor *connection = [connectedNeighbours objectForKey:uid];
	[connectedNeighbours removeObjectForKey:uid];
	
	return connection;
}

- (bool) hasConnectedNeighbour:(NSNumber*) neighbour
{
	return [[connectedNeighbours allKeys] containsObject:neighbour];
}

- (NSArray*) getConnectedNeighbours
{
	return [connectedNeighbours allKeys];
}

- (int) connectedNeighboursCount
{
	return [connectedNeighbours count];
}

- (void) setColor:(RGBA) aColor
{
	color = aColor;
	newColor = aColor;
}

- (void) randomizeColor
{
	if(color.r != newColor.r)
	{
		if((color.r > newColor.r) && (colorStep.r > 0))
		{
			newColor.r = (((float)(arc4random() % 1000)) / 1000);
			colorStep.r = (newColor.r - color.r) / 60.0f;
		}
		if((color.r < newColor.r) && (colorStep.r < 0))
		{
			newColor.r = (((float)(arc4random() % 1000)) / 1000);
			colorStep.r = (newColor.r - color.r) / 60.0f;
		}
		color.r += colorStep.r;
	}
	else
	{
		newColor.r = (((float)(arc4random() % 1000)) / 1000);
		colorStep.r = (newColor.r - color.r) / 60.0f;
	}
	
	if(color.g != newColor.g)
	{
		if((color.g > newColor.g) && (colorStep.g > 0))
		{
			newColor.g = (((float)(arc4random() % 1000)) / 1000);
			colorStep.g = (newColor.g - color.g) / 60.0f;
		}
		if((color.g < newColor.g) && (colorStep.g < 0))
		{
			newColor.g = (((float)(arc4random() % 1000)) / 1000);
			colorStep.g = (newColor.g - color.g) / 60.0f;
		}
		color.g += colorStep.g;
	}
	else
	{
		newColor.g = (((float)(arc4random() % 1000)) / 1000);
		colorStep.g = (newColor.g - color.g) / 60.0f;
	}
	
	if(color.b != newColor.b)
	{
		if((color.b > newColor.b) && (colorStep.b > 0))
		{
			newColor.b = (((float)(arc4random() % 1000)) / 1000);
			colorStep.b = (newColor.b - color.b) / 60.0f;
		}
		if((color.b < newColor.b) && (colorStep.b < 0))
		{
			newColor.b = (((float)(arc4random() % 1000)) / 1000);
			colorStep.b = (newColor.b - color.b) / 60.0f;
		}	
		color.b += colorStep.b;
	}
	else
	{
		newColor.b = (((float)(arc4random() % 1000)) / 1000);
		colorStep.b = (newColor.b - color.b) / 60.0f;
	}
}

@end
