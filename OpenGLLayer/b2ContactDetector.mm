//
//  b2ContactDetector.mm
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/20/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "b2ContactDetector.h"

b2ContactDetector::b2ContactDetector(id objectiveBridge)
{
	_objectiveBridge = objectiveBridge;
}

void b2ContactDetector::BeginContact(b2Contact *contact)
{
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	
	if ((fixtureA->IsSensor()) && (fixtureB->IsSensor()))
	{
		[_objectiveBridge contactBetween:(InteractiveObject*)fixtureA->GetBody()->GetUserData() And:(InteractiveObject*)fixtureB->GetBody()->GetUserData()];
	}
}

void b2ContactDetector::EndContact(b2Contact *contact)
{
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	
	if ((fixtureA->IsSensor()) && (fixtureB->IsSensor()))
	{
		[_objectiveBridge removedContactBetween:(InteractiveObject*)fixtureA->GetBody()->GetUserData() And:(InteractiveObject*)fixtureB->GetBody()->GetUserData()];
	}
}