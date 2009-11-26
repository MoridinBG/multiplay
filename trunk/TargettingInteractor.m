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
@synthesize startPositionOnTrajectory;
@synthesize endPositionOnTrajectory;

@synthesize isAimless;

@synthesize curving;
@synthesize controlPointDistance;

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

- (void) calculateBezierTrajectoryWithStart:(CGPoint)start andEnd:(CGPoint)end
{
	float newA, newB;
	float a = start.y - end.y;
	float b = start.x - end.x;
	float c = sqrt(a*a + b*b);
	float cosine = b / c;
	
	c *= curving;
	
	newB = cosine * c;
	newA = sqrt(c * c - newB * newB);
	if(end.y > start.y)
		newA = -newA;
	
	CGPoint midPoint = {newB + end.x, newA + end.y};

	float dx = start.x - end.x;
	float dy = start.y - end.y;
	float dist = sqrt(dx * dx + dy * dy);
	dx /= dist;
	dy /= dist;
	
//	float parameterStep = 0.03;
	CGPoint thirdPoint = {midPoint.x - dy * controlPointDistance, midPoint.y + dx * controlPointDistance};
	[trajectory removeAllObjects];
	for(float t = 0; t < 1; t += 0.01)
	{
		CGPoint point;
		point.x = start.x * (1 - t) * (1 - t) + 2 * (1 - t) * t * thirdPoint.x + t * t * end.x;
		point.y = start.y * (1 - t) * (1 - t) + 2 * (1 - t) * t * thirdPoint.y + t * t * end.y;
		[trajectory addObject:[[PointObj alloc] initWithPoint:point]];
	}
}
@end