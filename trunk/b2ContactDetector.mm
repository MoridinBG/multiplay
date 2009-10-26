/*
 *  b2ContactDetector.cpp
 *  Finger
 *
 *  Created by Mood on 8/28/09.
 *  Copyright 2009 The Pixel Factory. All rights reserved.
 *
 */

#import "b2ContactDetector.h"
#import "SineConnect.h"

b2ContactDetector::b2ContactDetector()
{
}

void b2ContactDetector::Add(const b2ContactPoint* point)
{
	b2Shape* firstShape = point->shape1;
	b2Shape* secondShape = point->shape2;
	if((firstShape->IsSensor() == true) || (secondShape->IsSensor() == true))
	{
		[effectProvider contactBetween:(NSNumber*)firstShape->GetBody()->GetUserData() And:(NSNumber*)secondShape->GetBody()->GetUserData()];
		
	}
}

void b2ContactDetector::Persist(const b2ContactPoint* point)
{
	b2Shape* firstShape = point->shape1;
	b2Shape* secondShape = point->shape2;
	if((firstShape->IsSensor() == true) || (secondShape->IsSensor() == true))
	{
		[effectProvider updateContactBetween:(NSNumber*)firstShape->GetBody()->GetUserData() And:(NSNumber*)secondShape->GetBody()->GetUserData()];
	}
}

void b2ContactDetector::Remove(const b2ContactPoint* point)
{
	b2Shape* firstShape = point->shape1;
	b2Shape* secondShape = point->shape2;
	if((firstShape->IsSensor() == true) || (secondShape->IsSensor() == true))
	{
		[effectProvider removeContactBetween:(NSNumber*)firstShape->GetBody()->GetUserData() And:(NSNumber*)secondShape->GetBody()->GetUserData()];
	}
}

void b2ContactDetector::Result(const b2ContactResult* point)
{
}

void b2ContactDetector::setProvider(EffectProvider <ProximitySensorProtocol> *provider)
{
	effectProvider = provider;
}