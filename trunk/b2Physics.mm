//
//  b2Physics.m
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import "b2Physics.h"


@implementation b2Physics
- (id) initWithDimensions:(CGSize) dimensions withFrame:(bool) frame
{
	if(self = [super init])
	{
		b2AABB worldAABB;
		b2Vec2 gravity;
		if(!frame)
			gravity = b2Vec2(0.0f, 0.0f);
		else 
			gravity = b2Vec2(0.0f, 0.0f);
		bool doSleep = true;

		worldAABB.lowerBound.Set(-dimensions.width, -dimensions.height);
		worldAABB.upperBound.Set(2 * dimensions.width, 2 * dimensions.height);
		
		world = new b2World(worldAABB,gravity, doSleep);
		
		if(frame)
			[self createFrameWithDimensions:dimensions];
		
		if(RENDER_BOX2D_DEBUG_DRAW)
		{
			uint32 flags = 0;
			flags += 1			* b2DebugDraw::e_shapeBit;
			flags += 1			* b2DebugDraw::e_jointBit;
			flags += 0			* b2DebugDraw::e_coreShapeBit;
			flags += 0			* b2DebugDraw::e_aabbBit;
			flags += 0			* b2DebugDraw::e_obbBit;
			flags += 0			* b2DebugDraw::e_pairBit;
			flags += 0			* b2DebugDraw::e_centerOfMassBit;
			debugDraw.SetFlags(flags);
			world->SetDebugDraw(&debugDraw);
		}
	}
	
	return self;
}

- (void) createFrameWithDimensions:(CGSize) dimensions;
{
	b2BodyDef bd;
    b2PolygonDef sd;
	sd.restitution = 1.0f;
	float width = dimensions.width;
	float height = dimensions.height;
	
    bd.position.Set(width / 2, height / 2);
    frame = world->CreateBody(&bd);
	
    sd.SetAsBox(width / 2, 0.05f, b2Vec2(0.0f, height / 2 + 0.045f), 0.0f);
    frame->CreateShape(&sd);
	
    sd.SetAsBox(width / 2, 0.05f, b2Vec2(0.0f, -height / 2 - 0.045f), 0.0f);
    frame->CreateShape(&sd);
	
    sd.SetAsBox(0.05f, height / 2, b2Vec2(width / 2 + 0.045f, 0.0f), 0.0f);
    frame->CreateShape(&sd);
	
    sd.SetAsBox(0.05f, height / 2, b2Vec2(- width / 2 - 0.045f, 0.0f), 0.0f);
    frame->CreateShape(&sd); 
}

- (void) step
{
	world->Step(1.0f / 20.0f, 5);
}

- (b2ContactDetector*) addContactDetector
{
	b2ContactDetector *detector = new b2ContactDetector();
	world->SetContactListener(detector);
	return detector;
}

- (b2Body*) addProximityContactListenerAtX:(float)x Y:(float)y withUid:(NSNumber*)uid
{
	b2BodyDef bodyDef;
	bodyDef.position.Set(x, y);
	b2Body *body = world->CreateBody(&bodyDef);
	body->AllowSleeping(false);
	
	b2CircleDef shapeDef;
	shapeDef.radius = (SENSOR_RANGE);
	shapeDef.density = 1.0f;
	shapeDef.restitution = 0.0f;
	shapeDef.localPosition.Set(0.0f, 0.0f);
	shapeDef.isSensor = true;
	
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	body->SetUserData(uid);
	
	return body;
}

- (void*) createCirclularBodyWithRadius:(float)radius atPosition:(CGPoint)position
{
	b2BodyDef bodyDef;
	bodyDef.position.Set(position.x, position.y);
	b2Body *body  = world->CreateBody(&bodyDef);
	
	b2CircleDef shapeDef;
	shapeDef.radius = radius;
	shapeDef.density = 100.f;
	shapeDef.restitution = 1.f;
	
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	
	return body;
}

- (void*) createRectangularBodyWithSize:(CGSize)size atPosition:(CGPoint)position
{
	size.width *= 1.025;
	size.height *= 1.025;
	b2BodyDef bodyDef;
    bodyDef.position.Set(position.x, position.y);
    b2Body *body = world->CreateBody(&bodyDef);
	
	b2PolygonDef shapeDef;
	shapeDef.SetAsBox(size.width / 2, size.height / 2, b2Vec2(size.width / 2, size.height / 2), 0);
	shapeDef.density = 100.0f;
	shapeDef.restitution = 1.0f;
	
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	
	return body;
}

- (void) destroyBody:(b2Body*) body
{
	if(body)
		world->DestroyBody(body);
}

- (CGPoint) getCoordinatesFromBody:(b2Body*) body
{
	CGPoint position = {body->GetPosition().x, body->GetPosition().y};
	return position;
}
@end
