//
//  AlphaChangeContainer.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 6/7/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "AlphaChangeContainer.h"


@implementation AlphaChangeContainer

@synthesize alpha = _alpha;
@synthesize changeSign = _changeSign;

@synthesize framesTillChange = _framesTillChange;
@synthesize changeStep = _changeStep;

- (id) initRandom
{
	if(self = [super init])
	{
		_alpha = ((arc4random() % 100) >= 50) ? 1.f : 0.f;
		_changeSign = (_alpha == 1.f) ? -1 : 1;
		_framesTillChange = 10 +  (arc4random() % 50);
		_changeStep = 1.f / _framesTillChange;
	}
	return self;
}

@end
