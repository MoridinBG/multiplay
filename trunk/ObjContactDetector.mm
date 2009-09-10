//
//  ObjContactDetector.mm
//  Finger
//
//  Created by Mood on 8/28/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "ObjContactDetector.h"

@implementation ObjContactDetector
@synthesize detector;
- (id) init
{
	if(self = [super init])
	{
		detector = new b2ContactDetector();
	}
	return self;
}

- (void) contactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
}

- (void) updateContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
}

- (void) removeContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID
{
}

@end
