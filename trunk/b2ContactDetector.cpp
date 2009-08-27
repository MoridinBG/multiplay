/*
 *  b2ContactDetector.cpp
 *  Finger
 *
 *  Created by Mood on 8/28/09.
 *  Copyright 2009 The Pixel Factory. All rights reserved.
 *
 */

#include "b2ContactDetector.h"

void b2ContactDetector::Add(const b2ContactPoint* point)
{
	
	b2Shape* firstShape = point->shape1;
	b2Shape* secondShape = point->shape2;
	if((firstShape->IsSensor() == true) && (secondShape->IsSensor() == true))
	{
//		emit contact(((TouchContact*)firstShape->GetBody()->GetUserData()), ((TouchContact*)secondShape->GetBody()->GetUserData()));
	}
}

void b2ContactDetector::Persist(const b2ContactPoint* point)
{
	b2Shape* firstShape = point->shape1;
	b2Shape* secondShape = point->shape2;
	if((firstShape->IsSensor() == true) && (secondShape->IsSensor() == true))
	{
//		emit updateContact(((TouchContact*)firstShape->GetBody()->GetUserData()), ((TouchContact*)secondShape->GetBody()->GetUserData()));
	}
}

void b2ContactDetector::Remove(const b2ContactPoint* point)
{
	b2Shape* firstShape = point->shape1;
	b2Shape* secondShape = point->shape2;
	if((firstShape->IsSensor() == true) && (secondShape->IsSensor() == true))
	{
//		emit removeContact(((TouchContact*)firstShape->GetBody()->GetUserData()), ((TouchContact*)secondShape->GetBody()->GetUserData()));
	}
}