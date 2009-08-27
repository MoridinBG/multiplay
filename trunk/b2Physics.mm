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
		
		worldAABB.lowerBound.Set(-3.2, -2.0);
		worldAABB.upperBound.Set(3.2, 2.0);
		world = new b2World(worldAABB,gravity, doSleep);
	}
	return self;
}

- (void) setContactListener:(b2ContactDetector*) detector
{
	world->SetContactListener(detector);
}

- (b2Body*) addContactDetectorAtX:(float) x Y:(float) y
{
	b2BodyDef bodyDef;
//	bodyDef.position.Set(x / SCALE_FACTOR, y / SCALE_FACTOR);
	b2Body *body = world->CreateBody(&bodyDef);
	
	b2CircleDef shapeDef;
//	shapeDef.radius = (CONTACT_RANGE / SCALE_FACTOR);
	shapeDef.density = 10000.0f;
	shapeDef.restitution = 0.0f;
	shapeDef.localPosition.Set(0.0f, 0.0f);
	shapeDef.isSensor = true;
	
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	
	return body;
}
@end
