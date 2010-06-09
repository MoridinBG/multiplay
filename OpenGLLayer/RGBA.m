//
//  RGBA.m
//  Finger
//
//  Created by Ivan Dilchovski on 12/27/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "RGBA.h"


@implementation RGBA
@synthesize r = _r;
@synthesize g = _g;
@synthesize b = _b;
@synthesize a = _a;

- (id) initWithR:(float) r
		   withG:(float) g
		   withB:(float) b
		   withA:(float) a
{
	if(self = [super init])
	{
		_r = r;
		_g = g;
		_b = b;
		_a = a;
	}
	
	return self;
}

+ (id) randomColorWithMinimumValue:(int)minColor
{
	return [[RGBA alloc] initWithR:(((float)(minColor + (arc4random() % 215)) / 255))
							  withG:(((float)(minColor + (arc4random() % 215)) / 255))
							  withB:(((float)(minColor + (arc4random() % 215)) / 255))
							  withA:1.f];
}

@end
