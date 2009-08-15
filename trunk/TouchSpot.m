//
//  TouchSpot.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/4/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "TouchSpot.h"

@implementation TouchSpot

@synthesize scale;
@synthesize angle;
@synthesize isScaling;
@synthesize position;
@synthesize isNew;
@synthesize delta;

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
@end
