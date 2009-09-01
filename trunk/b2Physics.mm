//
//  b2Physics.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import "b2Physics.h"


@implementation b2Physics
- (void) main
{
	b2AABB worldAABB;
	b2Vec2 gravity(0.0f, 0.0f);
	bool doSleep = true;
	
	worldAABB.lowerBound.Set(-5.0, -5.0);
	worldAABB.upperBound.Set(5.0, 5.0);
	
	world = new b2World(worldAABB,gravity, doSleep);
	
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
	world->Step(1.0f / 30.0f, 5);
	[mutex unlock];
}

- (b2ContactDetector*) addContactDetector
{
	[mutex lock];
	
	b2ContactDetector *detector = new b2ContactDetector();
	world->SetContactListener(detector);
	
	[mutex unlock];
	return detector;
}

- (void) destroyBody:(b2Body*) body
{
	[mutex lock];
	if(body)
		world->DestroyBody(body);
	[mutex unlock];
}

- (b2Body*) addContactListenerAtX:(float) x Y:(float) y withUid:(NSNumber*) uid
{
	[mutex lock];
	b2BodyDef bodyDef;
	bodyDef.position.Set(x, y);
	b2Body *body = world->CreateBody(&bodyDef);
	
	b2CircleDef shapeDef;
	shapeDef.radius = (SENSOR_RANGE);
	shapeDef.density = 10000.0f;
	shapeDef.restitution = 0.0f;
	shapeDef.localPosition.Set(0.0f, 0.0f);
	shapeDef.isSensor = true;
	
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	body->SetUserData(uid);
	[mutex unlock];
	
	return body;
}
@end
