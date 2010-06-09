//
//  BulletPhysics.mm
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/14/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "BulletPhysics.h"

@implementation BulletPhysics

- (id) init
{
	if(self = [super init])
	{
		broadphase = new btDbvtBroadphase();
		
        collisionConfiguration = new btDefaultCollisionConfiguration();
        dispatcher = new btCollisionDispatcher(collisionConfiguration);
		solver = new btSequentialImpulseConstraintSolver;
		
        dynamicsWorld = new btDiscreteDynamicsWorld(dispatcher,broadphase,solver,collisionConfiguration);
		
		lastStepTime = mach_absolute_time();
		NSInvocationOperation* evolution = [[NSInvocationOperation alloc] initWithTarget:self
																				selector:@selector(step) 
																				  object:nil];
		
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue addOperation:evolution];
	}
	
	return self;
}

- (void) step
{
	while(1)
	{
		double lastTime = [GlobalFunctions substractStartTime:lastStepTime fromEndTime:mach_absolute_time()] * 100;
		lastStepTime = mach_absolute_time();
		dynamicsWorld->stepSimulation(lastTime, 6);
	}
}

@end
