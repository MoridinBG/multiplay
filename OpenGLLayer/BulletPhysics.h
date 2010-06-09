//
//  BulletPhysics.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/14/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <mach/mach_time.h>

#ifdef __cplusplus
	#import <BulletDynamics/btBulletDynamicsCommon.h>
#endif

#import "GlobalFunctions.h"

@interface BulletPhysics : NSObject 
{
	NSOperationQueue *operationQueue;
	uint64_t lastStepTime;
	
#ifdef __cplusplus	
	btBroadphaseInterface *broadphase;
	btDefaultCollisionConfiguration* collisionConfiguration;
	btCollisionDispatcher* dispatcher;
	btSequentialImpulseConstraintSolver* solver;
	
	btDiscreteDynamicsWorld* dynamicsWorld;
#endif
}

- (id) init;
- (void) step;

@end
