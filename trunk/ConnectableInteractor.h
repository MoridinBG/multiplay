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

@interface ConnectableInteractor : InteractiveObject
{
	LiteTouchInfo targetObject;
	NSMutableArray *connectees;
}
@property LiteTouchInfo targetObject;

- (void) setTargetObject:(NSNumber*) targetUid withPosition:(CGPoint) pos;

- (void) addConnectee:(NSNumber*) uid;
- (bool) containstConnectee:(NSNumber*) uid;
- (NSMutableArray*) getConnectees;
- (bool) hasConnectees;
- (void) removeConnectee:(NSNumber*) uid;

@end
