//
//  ContactDetector.mm
//  Finger
//
//  Created by Mood on 8/7/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "ObjGhost.h"

@implementation ObjGhost
@synthesize ghost;

- (id) init
{
	if(self = [super init])
	{
		ghost = new btGhostObject();
		ghost->setCollisionFlags(ghost->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE);
	}
	return self;
}
@end
