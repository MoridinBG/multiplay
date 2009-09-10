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
	CGPoint targetCache;
	CGPoint originCache;
}
@property (copy) NSNumber *origin;
@property (copy) NSNumber *target;

@property CGPoint targetCache;
@property CGPoint originCache;

- (id) initWithOrigin:(NSNumber*) aOrigin target:(NSNumber*) aTarget;

@end
