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

@synthesize isAimless;

- (id) initWithOrigin:(NSNumber*) aOrigin target:(NSNumber*) aTarget
{
	if(self = [super init])
	{
		origin = aOrigin;
		target = aTarget;
		
		isAimless = FALSE;
	}
	
	return self;
}

@end