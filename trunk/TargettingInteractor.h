//
//  ConnectableInteractor.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/4/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InteractiveObject.h"
#import "LiteTouchInfo.h"

@interface TargettingInteractor : InteractiveObject
{
	NSNumber *origin;
	NSNumber *target;
	float distance;
	CGPoint targetCache;
}
@property (copy) NSNumber *origin;
@property (copy) NSNumber *target;
@property float distance;
@property CGPoint targetCache;
@end
