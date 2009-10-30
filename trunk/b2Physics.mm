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
		
		mouseJoints = [[NSMutableDictionary alloc] initWithCapacity:MAX_TOUCHES];
		lock = [[NSRecursiveLock alloc] init];
	}
	
	return self;
}

- (void) createFrameWithDimensions:(CGSize) dimensions;
{
	b2BodyDef bd;
    b2PolygonDef sd;
	sd.restitution = 0.35f;
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
	[lock lock];
	world->Step(1.0f / 20.0f, 5);
	[lock unlock];
}

- (b2ContactDetector*) addContactDetector
{
	[lock lock];
	b2ContactDetector *detector = new b2ContactDetector();
	world->SetContactListener(detector);
	[lock unlock];
	
	return detector;
}

- (b2Body*) addProximityContactListenerAtX:(float)x Y:(float)y withUid:(NSNumber*)uid
{
	[lock lock];
	b2BodyDef bodyDef;
	bodyDef.position.Set(x, y);
	b2Body *body = world->CreateBody(&bodyDef);
	body->AllowSleeping(false);
	
	b2CircleDef shapeDef;
	shapeDef.radius = (SENSOR_RANGE);
	shapeDef.density = 1.0f;
	shapeDef.localPosition.Set(0.0f, 0.0f);
	shapeDef.isSensor = true;
	
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	body->SetUserData(uid);
	[lock unlock];
	
	return body;
}

- (void*) createCirclularBodyWithRadius:(float)radius atPosition:(CGPoint)position
{
	[lock lock];
	b2BodyDef bodyDef;
	bodyDef.position.Set(position.x, position.y);
	b2Body *body  = world->CreateBody(&bodyDef);
	
	b2CircleDef shapeDef;
	shapeDef.radius = radius;
	shapeDef.density = 1.f;
	shapeDef.restitution = 0.1;
	
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	[lock unlock];
	
	return body;
}

- (void*) createRectangularBodyWithSize:(CGSize)size atPosition:(CGPoint)position rotatedAt:(float)angle
{
	[lock lock];
	size.width *= 1.025;
	size.height *= 1.025;
	b2BodyDef bodyDef;
    bodyDef.position.Set(position.x, position.y);
    b2Body *body = world->CreateBody(&bodyDef);
	
	b2PolygonDef shapeDef;
	shapeDef.SetAsBox(size.width / 2, size.height / 2, b2Vec2(size.width / 2, size.height / 2), angle);
	shapeDef.density = 1.0f;
	shapeDef.friction = 0.5f;
	shapeDef.restitution = 0.35f;
	
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	[lock unlock];
	
	return body;
}

- (void) reshapeRectangularBody:(b2Body*)body withNewSize:(CGSize)newSize rotatedAt:(float)angle
{
	body->DestroyShape(body->GetShapeList());
	
	b2PolygonDef shapeDef;
	shapeDef.SetAsBox(newSize.width / 2, newSize.height / 2, b2Vec2(newSize.width / 2, newSize.height / 2), angle);
	shapeDef.density = 1.0f;
	shapeDef.friction = 0.5f;
	shapeDef.restitution = 0.35f;
	
	body->CreateShape(&shapeDef);
}

- (void) destroyBody:(b2Body*) body
{
	[lock lock];
	if(body)
		world->DestroyBody(body);
	[lock unlock];
}

- (CGPoint) getCoordinatesFromBody:(b2Body*) body
{
	[lock lock];
	CGPoint position = {body->GetPosition().x, body->GetPosition().y};
	[lock unlock];
	
	return position;
}

- (void) attachMouseJointToBody:(b2Body*)body withId:(NSNumber*)uid
{
	[lock lock];
	b2MouseJointDef mouseDef;
	mouseDef.body1 = world->GetGroundBody();
	mouseDef.body2 = body;
	mouseDef.target = body->GetWorldCenter();
	mouseDef.maxForce = PHYSICS_DRAG_ELASTICITY * body->GetMass();
	
	[mouseJoints setObject:[NSValue valueWithPointer:world->CreateJoint(&mouseDef)] forKey:uid];
	[lock unlock];
}

- (void) detachMouseJointWithId:(NSNumber*)uid
{
	[lock lock];
	if([mouseJoints objectForKey:uid])
	{
		b2MouseJoint *joint = (b2MouseJoint*) [[mouseJoints objectForKey:uid] pointerValue];
		world->DestroyJoint(joint);
		[mouseJoints removeObjectForKey:uid];
	}
	[lock unlock];
}

- (void) updateMouseJointWithId:(NSNumber*)uid toPosition:(CGPoint)position;
{
	[lock lock];
	if([mouseJoints objectForKey:uid])
	{
		b2MouseJoint *joint = (b2MouseJoint*) [[mouseJoints objectForKey:uid] pointerValue];
		joint->SetTarget(b2Vec2(position.x, position.y));
	}
	[lock unlock];
}
@end
