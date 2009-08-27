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
	LiteTouchInfo target;
	NSMutableArray *connectees;
}
@property LiteTouchInfo target;

- (void) setTarget:(NSNumber*) targetUid withPosition:(CGPoint) pos;

- (void) addConnectee:(NSNumber*) uid;
- (bool) containstConnectee:(NSNumber*) uid;
- (NSMutableArray*) getConnectees;
- (bool) hasConnectees;
- (void) removeConnectee:(NSNumber*) uid;

@end
