//
//  ConnectableInteractor.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/4/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "ConnectableInteractor.h"

@implementation ConnectableInteractor

@synthesize target;

- (void) setTarget:(NSNumber*) targetUid withPosition:(CGPoint) pos
{
	LiteTouchInfo newTarget = {targetUid, pos};
	target = newTarget;
}

- (void) addConnectee:(NSNumber*) uid
{
	[connectees addObject:uid];
}

- (NSMutableArray*) getConnectees
{
	return connectees;
}

- (bool) containstConnectee:(NSNumber*) uid
{
	return [connectees containsObject:uid];
}

- (bool) hasConnectees
{
	return ([connectees count] > 0);
}

- (void) removeConnectee:(NSNumber*) uid
{
	[connectees removeObject:uid];
}

@end
