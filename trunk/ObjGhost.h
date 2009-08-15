//
//  ObjGhost.h
//  Finger
//
//  Created by Mood on 8/7/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#ifdef __cplusplus
	#import <BulletCollision/btBulletCollisionCommon.h>
	#import <BulletCollision/CollisionDispatch/btGhostObject.h>
#endif

@interface ObjGhost : NSObject 
{
#ifdef __cplusplus
	btGhostObject *ghost;
#endif
}

#ifdef __cplusplus
@property (readonly) btGhostObject* ghost;
#endif

- (id) init;

@end
