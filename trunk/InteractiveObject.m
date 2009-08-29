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

- (id) initWithPos:(CGPoint) pos
{
	if(self = [super init])
	{
		position = pos;
		scale = 0.01f;
		angle = 0.0f;
		isScaling = TRUE;
		isNew = TRUE;
		delta = 0.08;
		
		neighbours = [[NSMutableArray alloc] init];
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

@end
