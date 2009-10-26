//
//  ElasticValuator.h
//  Finger
//
//  Created by Ivan Dilchovski on 10/21/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ElasticValuator : NSObject 
{
	float start, end, value;
	float elasticity;
	int steps;
	float changeStep;
	bool negative;
}
@property float start;
@property float end;
@property float value;
@property float elasticity;
@property int steps;
@property float changeStep;

- (id) initWithStartValue:(float)start endValue:(float)end inNumSteps:(int) steps withElasticity:(float)elasticity;

- (void) step;
- (float) stepAndGet;
@end
