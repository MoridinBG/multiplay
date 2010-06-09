//
//  Connector.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/20/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "Connection.h"


@implementation Connection
@synthesize endA = _endA;
@synthesize endB = _endB;

@dynamic length;
@dynamic connectionAngle;

@synthesize begin = _begin;
@synthesize end = _end;

@synthesize isReadyToDie = _isReadyToDie;

- (id) initWithendA:(InteractiveObject*) endA
			  endB:(InteractiveObject*) endB
		   beginningAt:(float) beginnning
			  endingAt:(float)ending
{
	if(self = [super init])
	{
		if(endA.position.x <= endB.position.x)
		{
			_endA = endA;
			_endB = endB;
		} else 
		{
			_endA = endB;
			_endB = endA;
		}

		_begin = beginnning;
		_end = ending;
	}
	return self;
}

#pragma mark Property Accessors
- (float) length
{
	return [GlobalFunctions lengthBetweenPoint:_endA.position andPoint:_endB.position];
}

- (float) connectionAngle
{
	return [GlobalFunctions findAngleBetweenPoint:_endA.position andPoint:_endB.position];
}
#pragma mark -
@end
