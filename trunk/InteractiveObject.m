//
//  InteractiveObject.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import "InteractiveObject.h"

@implementation InteractiveObject

@synthesize neighbours;
@synthesize connectedNeighbours;

@synthesize newColor;
@synthesize colorStep;
@synthesize colorSpeed;
@synthesize alphaDelta;

@synthesize scale;
@synthesize delta;
@synthesize targetScale;

@synthesize angle;
@synthesize position;

@synthesize isScaling;
@synthesize isNew;

@synthesize physicsData;
@synthesize color;

@synthesize itemsHeld;
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

- (id) copyWithZone:(NSZone *) zone
{
	InteractiveObject *newObject = [[InteractiveObject alloc] init];
	
	newObject.scale = self.scale;
	newObject.delta = self.delta;
	newObject.targetScale = self.targetScale;
	
	newObject.position = self.position;
	newObject.direction = self.direction;
	
	newObject.isScaling = self.isScaling;
	newObject.isNew = self.isNew;
	
	newObject.itemsHeld = self.itemsHeld;
	newObject.isHolding = self.isHolding;
	
	newObject.angle = self.angle;
	newObject.rotateLeft = self.rotateLeft;
	newObject.rotateDelta = self.rotateDelta;
	
	newObject.color = self.color;
	newObject.newColor = self.newColor;
	newObject.colorStep = self.colorStep;
	newObject.colorSpeed = self.colorSpeed;
	newObject.alphaDelta = self.alphaDelta;
	
	return newObject;
}

- (void) setAngle:(float) newAngle
{
	angle = newAngle;
	
	if(angle > 0)
		while(angle >= 360.f)
		{
			angle -= 360.f;
		}
	else
		while(angle <= -360.f)
		{
			angle += 360.f;
		}
}

- (void) render
{
}

- (id) init
{
	if(self = [super init])
	{
		scale = 0.01f;
		delta = 0.18;
		targetScale = 1.f;																			//Used to hold specific target values for scale;
		
		isScaling = TRUE;
		isNew = TRUE;
		
		angle = 0.0f;
		rotateDelta = 3.0;
		if((arc4random() % 100) > 50)
			rotateLeft = TRUE;
		else
			rotateLeft = FALSE;
		
		neighbours = [[NSMutableArray alloc] init];
		connectedNeighbours = [[NSMutableDictionary alloc] initWithCapacity:100];
		
		[self setRandomColor];
		colorSpeed = 1.0f;
		
	}
	return self;
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
			newColor.r = (((float)(arc4random() % 255)) / 255);
			colorStep.r = (newColor.r - color.r) / 60.0f;
		}
		if((color.r < newColor.r) && (colorStep.r < 0))
		{
			newColor.r = (((float)(arc4random() % 255)) / 255);
			colorStep.r = (newColor.r - color.r) / 60.0f;
		}
		colorStep.r *= colorSpeed;
		color.r += colorStep.r;
	}
	else
	{
		newColor.r = (((float)(arc4random() % 255)) / 255);
		colorStep.r = (newColor.r - color.r) / 60.0f;
	}
	
	if(color.g != newColor.g)
	{
		if((color.g > newColor.g) && (colorStep.g > 0))
		{
			newColor.g = (((float)(arc4random() % 255)) / 255);
			colorStep.g = (newColor.g - color.g) / 60.0f;
		}
		if((color.g < newColor.g) && (colorStep.g < 0))
		{
			newColor.g = (((float)(arc4random() % 255)) / 255);
			colorStep.g = (newColor.g - color.g) / 60.0f;
		}
		colorStep.g *= colorSpeed;
		color.g += colorStep.g;
	}
	else
	{
		newColor.g = (((float)(arc4random() % 255)) / 255);
		colorStep.g = (newColor.g - color.g) / 60.0f;
	}
	
	if(color.b != newColor.b)
	{
		if((color.b > newColor.b) && (colorStep.b > 0))
		{
			newColor.b = (((float)(arc4random() % 255)) / 255);
			colorStep.b = (newColor.b - color.b) / 60.0f;
		}
		if((color.b < newColor.b) && (colorStep.b < 0))
		{
			newColor.b = (((float)(arc4random() % 255)) / 255);
			colorStep.b = (newColor.b - color.b) / 60.0f;
		}
		colorStep.b *= colorSpeed;
		color.b += colorStep.b;
	}
	else
	{
		newColor.b = (((float)(arc4random() % 255)) / 255);
		colorStep.b = (newColor.b - color.b) / 60.0f;
	}
}

- (void) setRandomColor
{
	color.r = (((float)(arc4random() % 255)) / 255);
	color.g = (((float)(arc4random() % 255)) / 255);
	color.b = (((float)(arc4random() % 255)) / 255);
	
	newColor = color;
}

@end
