//
//  btPhysics.mm
//  Finger
//
//  Created by Mood on 7/27/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "btPhysics.h"
/*extern ContactAddedCallback		gContactAddedCallback;

@implementation btPhysics
- (void) main
{
	//Setup physics world
	btVector3 worldAabbMin(-1000,-1000,-1000);
	btVector3 worldAabbMax(1000,1000,1000);
	int	maxProxies = 4096;
	
	btDefaultCollisionConfiguration* collisionConfiguration = new btDefaultCollisionConfiguration();
	btCollisionDispatcher* dispatcher = new	btCollisionDispatcher(collisionConfiguration);
	btAxisSweep3* overlappingPairCache = new btAxisSweep3(worldAabbMin,worldAabbMax,maxProxies);
	overlappingPairCache->getOverlappingPairCache()->setInternalGhostPairCallback(new btGhostPairCallback());
	btSequentialImpulseConstraintSolver* solver = new btSequentialImpulseConstraintSolver;
	
	dynamicsWorld = new btDiscreteDynamicsWorld(dispatcher,overlappingPairCache,solver,collisionConfiguration);		
	dynamicsWorld->setGravity(btVector3(0, 0, 0));
	
	mutex = [[NSLock alloc] init];
	
	NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.048
													  target:self 
													selector:@selector(step:) 
													userInfo:nil 
													 repeats:YES];
	[myRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
	[myRunLoop run];
}

- (void) step:(NSTimer*) theTimer
{
	[mutex lock];
	dynamicsWorld->stepSimulation(1.f/30.f,2);
	[mutex unlock];
}

- (void) addCollisionBody:(ObjGhost*) body
{
	dynamicsWorld->addCollisionObject([body ghost]);
}
@end
*/