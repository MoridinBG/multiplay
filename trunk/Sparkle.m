//
//  Sparkle.m
//  Finger
//
//  Created by Ivan Dilchovski on 9/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sparkle.h"


@implementation Sparkle
@synthesize position;
@synthesize direction;
@synthesize alpha;

- (id) initAtPosition:(CGPoint) aPosition withDirection:(CGPoint) aDirection withAlpha:(float) aAlpha
{
	if(self = [super init])
	{
		position = aPosition;
		direction = aDirection;
		alpha = aAlpha;
	}
	
	return self;
}

@end
