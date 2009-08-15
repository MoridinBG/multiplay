//
//  SparklesPhysics.mm
//  Finger
//
//  Created by Mood on 7/28/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "SparklesPhysics.h"

@implementation SparklesPhysics
- (void) main
{
	timers = [[NSMutableDictionary alloc] init];
	positions = [[NSMutableDictionary alloc] init];
	bodies = [[NSMutableDictionary alloc] init];
	
	mass = 0.1f;
	localInertia = btVector3(0, 0, 0);
	colShape = new btSphereShape(btScalar(35.0));
	colShape->calculateLocalInertia(mass,localInertia);
	
	[super main];
}

- (void) setPosition:(LiteTouchInfo) touch
{
	[mutex lock];
	
	//Set the position for this TouchID
	[positions setObject:[NSValue value:&touch.pos withObjCType:@encode(LiteTouchInfo)] forKey:touch.uid];
	
	//If there is no Body creatin timer for this TouchID (It's a TouchDown) create it.
	if(![timers objectForKey:touch.uid])
	{
		//Create a new body every 10ms
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.02
														  target:self 
														selector:@selector(createBody:) 
														userInfo:touch.uid
														 repeats:YES];
		[timers setObject:timer forKey:touch.uid];
	}
	[mutex unlock];
}

- (void) removePosition:(NSNumber*) uid
{
	[mutex lock];
	//Remove all objects associated with this TouchID
	[[timers objectForKey:uid] invalidate];
	[timers removeObjectForKey:uid];
	[positions removeObjectForKey:uid];
	
	//Delete all the bodies created and still alive around the touch
	NSMutableArray *bodiesForTouch = [bodies objectForKey:uid];
	NSValue *containedBody;
	for(containedBody in bodiesForTouch)
	{
		btRigidBody *body = (btRigidBody*) [containedBody pointerValue];
		dynamicsWorld->removeRigidBody(body);
		delete body;
	}
	
	[bodies removeObjectForKey:uid];
	[mutex unlock];
}

- (void) createBody:(NSTimer*) theTimer
{
	[mutex lock];
	CGPoint pos;
	btRigidBody *body;
	NSMutableArray *uuidBodies;
	
	//Calculate a random position around the touch
	[[positions objectForKey:[theTimer userInfo]] getValue:&pos];
	
	///A value between -0.05 and 0.05, that is added to the base coordinate
	float x = pos.x - ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.08);
	float y = pos.y - ((((float)(arc4random() % 10) / 10) * 2 - 1) * 0.08);

	//If there is a group of bodies associated with this TouchID
	if ([bodies objectForKey:[theTimer userInfo]]) 
	{
		uuidBodies = [bodies objectForKey:[theTimer userInfo]];
		//If there are 50 alive bodies remove one of them
		if([uuidBodies count] == 20)
		{
			body = (btRigidBody *)[[uuidBodies objectAtIndex:0] pointerValue] ;
			dynamicsWorld->removeRigidBody(body);
			[uuidBodies removeObjectAtIndex:0];
			delete body;
		}
	}
	else
	{
		//If this would be the first body for this TouchID, create a group
		uuidBodies = [[NSMutableArray alloc] initWithCapacity:51];
		[bodies setObject:uuidBodies forKey:[theTimer userInfo]];
	}
	
	//Create a Bullet Physics Body
	btTransform startTransform;
	startTransform.setIdentity();
	startTransform.setOrigin(btVector3(x * 1000,y * 1000,0));
	
	delete myMotionState;

	myMotionState = new btDefaultMotionState(startTransform);
	btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, myMotionState, colShape, localInertia);
	body = new btRigidBody(rbInfo);
	dynamicsWorld->addRigidBody(body);
	
	[uuidBodies addObject:[NSValue valueWithPointer:body]];
	[mutex unlock];
}

- (NSMutableDictionary*) getPositions
{
	[mutex lock];
	//Get all Body group TouchIDs
	NSArray *keys = [bodies allKeys];
	NSNumber *key;
	NSArray *bodiesGroup;
	NSMutableDictionary *groupedPositions = [[NSMutableDictionary alloc] initWithCapacity:[bodies count]];
	NSValue *encapsulatedBody;
	btRigidBody *body;
	
	//Iterate over TouchIDs
	for(key in keys)
	{
		//Get bodies for TouchID
		bodiesGroup = [bodies objectForKey:key];
		NSMutableArray *positionsGroup = [[NSMutableArray alloc] initWithCapacity:51];
		//Iterate over bodies for this TouchID
		for(encapsulatedBody in bodiesGroup)
		{
			body = (btRigidBody *)[encapsulatedBody pointerValue];
			btVector3 center = body->getCenterOfMassPosition();
			
			//Extract it's coordinates from the physics simulation
			NSPoint position = {center.getX() / 1000, center.getY() / 1000};
			[positionsGroup addObject:[NSValue valueWithPoint:position]];
		}
		//Add to other Body groups
		[groupedPositions setObject:positionsGroup forKey:key];
	}
	[mutex unlock];
	return groupedPositions;
}
@end
