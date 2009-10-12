//
//  b2Physics.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
	#import "box2d/Box2D.h"
	#import "b2ContactDetector.h"
#endif
#import "consts.h"

@interface b2Physics : NSObject 
{
#ifdef __cplusplus
	b2World *world;
#endif	
}
- (id) init;
- (void) step;

#ifdef __cplusplus
- (b2ContactDetector*) addContactDetector;
- (void) destroyBody:(b2Body*) body;
- (b2Body*) addContactListenerAtX:(float) x Y:(float) y withUid:(NSNumber*) uid;
#endif

@end
