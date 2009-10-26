//
//  ElasticValuator.m
//  Finger
//
//  Created by Ivan Dilchovski on 10/21/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "ElasticValuator.h"


@implementation ElasticValuator
@synthesize start;
@synthesize end;
@synthesize value;
@synthesize elasticity;
@synthesize steps;
@synthesize changeStep;

- (id) initWithStartValue:(float)start endValue:(float)end inNumSteps:(int)steps withElasticity:(float)elasticity
{
	if(self = [super init])
	{
		self.start = start;
		self.value = start;
		self.end = end;
		self.steps = steps;
		self.elasticity = elasticity;
		self.changeStep = (end - start) / steps;
	}
	
	return self;
}

- (void) step
{

	value += changeStep;
}

- (float) stepAndGet
{
	return value += changeStep;
}
@end
