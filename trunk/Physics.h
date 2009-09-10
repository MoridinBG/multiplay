//
//  Physics.h
//  Finger
//
//  Created by Mood on 7/27/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//
#ifdef __cplusplus
	#import <BulletDynamics/btBulletDynamicsCommon.h>
	#import <BulletCollision/CollisionDispatch/btGhostObject.h>
#endif

#import <Cocoa/Cocoa.h>
#import "LiteTouchInfo.h"
#import "ObjGhost.h"

@interface Physics : NSThread 
{
#ifdef __cplusplus
	btDiscreteDynamicsWorld *dynamicsWorld;
#endif
	NSConnection *connection;
	NSLock *mutex;
}
- (void) main;
- (void) step:(NSTimer*) theTimer;

#ifdef __cplusplus
- (void) addCollisionBody:(ObjGhost*) body;
#endif
@end
