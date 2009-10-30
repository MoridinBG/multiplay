//
//  TouchEvent.m
//  Finger
//
//  Created by Ivan Dilchovski on 7/16/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "TouchEvent.h"


@implementation TouchEvent

@synthesize uid;
@synthesize pos;
@synthesize lastPos;
@synthesize touchDownPos;
@synthesize speed;
@synthesize type;
@synthesize ignoreEvent;

- (id) initWithId:(NSNumber*)aUid withType:(TouchType)aType atPos:(CGPoint)aPos
{
	if([super init])
	{
		[self setUid:aUid];
		[self setType:aType];
		[self setPos:aPos];
		[self setLastPos:aPos];
		[self setTouchDownPos:aPos];
		
		return self;
	}
	else 
	{
		return nil;
	}
}
@end
