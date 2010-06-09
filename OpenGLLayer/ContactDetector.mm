//
//  ContactDetector.mm
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/20/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "ContactDetector.h"

@implementation ContactDetector
@synthesize effect = _effect;
@synthesize box2DContactDetector = _box2DContactDetector;

- (id) init
{
	if(self = [super init])
	{
		_box2DContactDetector = new b2ContactDetector(self);
	}
	return self;
}

- (void) contactBetween:(InteractiveObject*)firstObj And:(InteractiveObject*)secondObj
{
	[_effect contactBetween:firstObj And:secondObj];
}

- (void) removedContactBetween:(InteractiveObject*)firstObj And:(InteractiveObject*)secondObj
{
	[_effect removedContactBetween:firstObj And:secondObj];
}

@end
