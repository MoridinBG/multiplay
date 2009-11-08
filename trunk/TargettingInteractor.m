//
//  ConnectableInteractor.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/4/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "TargettingInteractor.h"

@implementation TargettingInteractor
@synthesize target;
@synthesize origin;

@synthesize targetCache;
@synthesize originCache;

@synthesize targetColorCache;
@synthesize originColorCache;

@synthesize trajectory;

@synthesize isAimless;

- (id) initWithOrigin:(NSNumber*) aOrigin target:(NSNumber*) aTarget
{
	if(self = [super init])
	{
		origin = aOrigin;
		target = aTarget;
		
		trajectory = [[NSMutableArray alloc] init];
		
		isAimless = FALSE;
	}
	
	return self;
}

- (void) calculateTrajectoryWithStart:(CGPoint)start andEnd:(CGPoint)end
{
	float a = start.y - end.y;
	float b = start.x - end.x;
	float c = sqrt(a*a + b*b);
	
	float cosine = b / c;
	
	c *= 0.5f;
	cosine *= 1.4f;
	
	float newB = cosine * c;
	float newA = sqrt(c * c - newB * newB);
	if(end.y > start.y)
		newA = -newA;
	
	CGPoint newPosition = {newB + end.x, newA + end.y};
	[trajectory addObject:[[PointObj alloc] initWithPoint:newPosition]];
}
@end