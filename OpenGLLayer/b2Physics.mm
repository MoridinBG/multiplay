//
//  b2Physics.mm
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/15/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "b2Physics.h"

@implementation b2Physics

- (id) init
{
	if(self = [super init])
	{
		timeStep = 1.0f / 60.0f;
		velocityIterations = 10;
		positionIterations = 10;
		
		bool sleep = true;
		b2Vec2 gravity(0.0f, 0.0f);
		
		world =  new b2World(gravity, sleep);
		b2BodyDef frameBodyDef;
		_groundBody = world->CreateBody(&frameBodyDef);
		
		mouseJoints = [[NSMutableDictionary alloc] init];

/*
		uint32 flags = 0;
		flags += 1			* b2DebugDraw::e_shapeBit;
		flags += 1			* b2DebugDraw::e_jointBit;
		flags += 1			* b2DebugDraw::e_aabbBit;
		flags += 1			* b2DebugDraw::e_pairBit;
		flags += 1			* b2DebugDraw::e_centerOfMassBit;
		debugDraw.SetFlags(flags);
		world->SetDebugDraw(&debugDraw);
//*/
/*		
		NSInvocationOperation* evolution = [[NSInvocationOperation alloc] initWithTarget:self
																				selector:@selector(step) 
																				  object:nil];

		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue addOperation:evolution];
//*/
	}
	return self;
}

- (void) createGroundWithDimensions:(CGSize)dimensions
{
	float aspect = dimensions.width / dimensions.height;
	
	b2BodyDef frameBodyDef;
	
	frameBodyDef.position.Set(aspect / 2.f, 0.5f);
	
	b2Body* frameBody = world->CreateBody(&frameBodyDef);
	
	b2FixtureDef fixtureDef;
	fixtureDef.filter.categoryBits = 0x0002;
	fixtureDef.filter.maskBits = 0x0004;
	b2PolygonShape groundBox;
	
	groundBox.SetAsBox(aspect / 2.f, 0.05f, b2Vec2(0.f, 0.5f), 0.f);
	fixtureDef.shape = &groundBox;
	frameBody->CreateFixture(&fixtureDef);
	
	groundBox.SetAsBox(0.05f, 0.5f, b2Vec2(aspect / 2.f, 0.f), 0.f);
	fixtureDef.shape = &groundBox;
	frameBody->CreateFixture(&fixtureDef);
	
	groundBox.SetAsBox(aspect / 2.f, 0.05f, b2Vec2(0.f, -0.5f), 0.f);
	fixtureDef.shape = &groundBox;
	frameBody->CreateFixture(&fixtureDef);
	
	groundBox.SetAsBox(0.05f, 0.5f, b2Vec2(-aspect / 2.f, 0.f), 0.f);
	fixtureDef.shape = &groundBox;
	frameBody->CreateFixture(&fixtureDef);
}

- (void) step
{
//	while(1)
	{
//		uint64_t start = mach_absolute_time();
		world->Step(timeStep, velocityIterations, positionIterations);
		world->ClearForces();
/*
		uint64_t end = mach_absolute_time();
		uint64_t diff = end - start;
		
		Nanoseconds nanoSeconds = AbsoluteToNanoseconds( *(AbsoluteTime *) &diff );
		uint64_t microSeconds = *(uint64_t *) &nanoSeconds / 1000;
		int sleepTime = 16667 - microSeconds;
		
		if(sleepTime > 0)
			usleep(16667 - microSeconds);
//*/
	}
}

- (ContactDetector *) addContactDetector
{
	ContactDetector *contactDetector = [[ContactDetector alloc] init];
	world->SetContactListener(contactDetector.box2DContactDetector);
	
	return contactDetector;
}

#pragma mark Create/Destroy Bodies

- (InteractiveObject*) createPolygonBodyAtPosition:(CGPoint)position 
										  withSize:(CGSize)size 
										 rotatedAt:(float)angle 
{	
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(position.x, position.y);
	b2Body* body = world->CreateBody(&bodyDef);
	
	b2PolygonShape solidBox;
	solidBox.SetAsBox(size.width / 2.f,
						size.height / 2.f);
	
	b2FixtureDef fixtureDef;
	fixtureDef.filter.categoryBits = 0x0002;
	fixtureDef.filter.maskBits = 0x0004;
	fixtureDef.shape = &solidBox;
	fixtureDef.density = 1.0f;

	body->CreateFixture(&fixtureDef);
	
	size.width *= 1.23f;
	size.height *= 1.23f;
	
	InteractiveObject *objBody = [[InteractiveObject alloc] initAtPosition:position
																   atAngle:angle
																  withSize:size
														   physicsBackedBy:body
																  withType:RECTANGLE];
	body->SetUserData(objBody);
	
	return objBody;
}

- (InteractiveObject*) createCircleBodyAtPosition:(CGPoint)position 
										 withSize:(CGSize)size
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(position.x, position.y);
	
	b2Body* body = world->CreateBody(&bodyDef);
	
	b2CircleShape circle;
	circle.m_radius = size.width / 2.f;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 10.0f;
	fixtureDef.filter.categoryBits = 0x0004;
	fixtureDef.filter.maskBits = 0x0002;
	
	body->CreateFixture(&fixtureDef);
	
	size.height = size.width;
	
	InteractiveObject *objBody = [[InteractiveObject alloc] initAtPosition:position
																   atAngle:0.f 
																  withSize:size
														   physicsBackedBy:body
																  withType:CIRCLE];
	body->SetUserData(objBody);

	return objBody;
	
}

- (InteractiveObject*) createCircleSensorAtPosition:(CGPoint)position
										   withSize:(CGSize)size
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(position.x, position.y);
	
	b2Body* body = world->CreateBody(&bodyDef);
	
	b2CircleShape circle;
	circle.m_radius = size.width / 2.f;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 1.0f;
	fixtureDef.isSensor = true;
	
	body->CreateFixture(&fixtureDef);
	
	size.height = size.width;
	
	InteractiveObject *objBody = [[InteractiveObject alloc] initAtPosition:position
																   atAngle:0.f 
																  withSize:size
														   physicsBackedBy:body
																  withType:SENSOR];
	body->SetUserData(objBody);
	
	return objBody;
}

- (void) destroyBody:(NSValue*)packedBody
{
	world->DestroyBody((b2Body*)[packedBody pointerValue]);
}
#pragma mark -

#pragma mark Create/Destroy Mouse Joints
- (void) attachMouseJointToBody:(NSValue*)packedBody withId:(NSNumber*)uid
{
	b2Body* body = (b2Body*) [packedBody pointerValue];
	b2MouseJointDef mouseDef;
	mouseDef.bodyA = _groundBody;
	mouseDef.bodyB = body;
	mouseDef.target = body->GetWorldCenter();
	mouseDef.maxForce = PHYSICS_DRAG_ELASTICITY * body->GetMass();

	[mouseJoints setObject:[NSValue valueWithPointer:world->CreateJoint(&mouseDef)] forKey:uid];
}

- (void) detachMouseJointWithId:(NSNumber*)uid
{
	if([mouseJoints objectForKey:uid])
	{
		b2MouseJoint *joint = (b2MouseJoint*) [[mouseJoints objectForKey:uid] pointerValue];
		world->DestroyJoint(joint);
		[mouseJoints removeObjectForKey:uid];
	}
}

- (void) updateMouseJointWithId:(NSNumber*)uid toPosition:(CGPoint)position
{
	if([mouseJoints objectForKey:uid])
	{
		b2MouseJoint *joint = (b2MouseJoint*) [[mouseJoints objectForKey:uid] pointerValue];
		joint->SetTarget(b2Vec2(position.x, position.y));
	}
}
#pragma mark -

- (NSMutableArray *) createBlobAt:(CGPoint)position 
					   withRadius:(float) blobRadius
{
	int nodes = 30;
	NSMutableArray *objBodies = [[NSMutableArray alloc] initWithCapacity:nodes];
	float pointRadius = 0.025f;
	
	float twoPi = 2.0f * 3.14159f;
	
	ConstantVolumeJointDef springsDef;
	springsDef.frequencyHz = 10.f;
	springsDef.dampingRatio = 0.5f;
	
	b2BodyDef bd;

	
	for(int i = 0; i <= nodes - 1; i++)
	{
		CGPoint pointPosition = CGPointMake(position.x + blobRadius * cos(i * twoPi / nodes),
											position.y + blobRadius * sin(i * twoPi / nodes));
		InteractiveObject *objBody = [self createCircleBodyAtPosition:pointPosition
															 withSize:CGSizeMake(pointRadius, pointRadius)];
		springsDef.addBody((b2Body*)[objBody.physicsData pointerValue]);
		[objBodies addObject:objBody];
	}
	
	world->CreateJoint(&springsDef);
	
	return objBodies;
}

@end
