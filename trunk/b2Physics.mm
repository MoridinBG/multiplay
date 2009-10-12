//
//  b2Physics.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import "b2Physics.h"


@implementation b2Physics
- (id) init
{
	if(self = [super init])
	{
		b2AABB worldAABB;
		b2Vec2 gravity(0.0f, 0.0f);
		bool doSleep = true;
		
		worldAABB.lowerBound.Set(-6.6, -6.6);
		worldAABB.upperBound.Set(6.6, 6.6);
		
		world = new b2World(worldAABB,gravity, doSleep);
	}
	
	return self;
}

- (void) step
{
	world->Step(1.0f / 30.0f, 5);
}

- (b2ContactDetector*) addContactDetector
{
	b2ContactDetector *detector = new b2ContactDetector();
	world->SetContactListener(detector);
	return detector;
}

- (void) destroyBody:(b2Body*) body
{
	if(body)
		world->DestroyBody(body);
}

- (b2Body*) addContactListenerAtX:(float) x Y:(float) y withUid:(NSNumber*) uid
{
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
	
	return body;
}
@end
