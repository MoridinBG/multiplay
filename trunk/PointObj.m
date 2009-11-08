//
//  PointObj.m
//  Finger
//
//  Created by Ivan Dilchovski on 11/5/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "PointObj.h"

@implementation PointObj
@synthesize x;
@synthesize y;


- (id) initWithPoint:(CGPoint) point
{
	if(self = [super init])
	{
		x = point.x;
		y = point.y;
	}
	
	return self;
}

- (id) initWithX:(float)x Y:(float)y
{
	if(self = [super init])
	{
		self.x = x;
		self.y = y;
	}
	
	return self;
}

- (CGPoint) getCGPoint
{
	CGPoint point = {x, y};
	return point;
}

@end
