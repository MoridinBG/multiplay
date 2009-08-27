/*
 *  b2ContactDetector.h
 *  Finger
 *
 *  Created by Mood on 8/28/09.
 *  Copyright 2009 The Pixel Factory. All rights reserved.
 *
 */

#ifndef B2CONTACTDETECTOR_H
#define B2CONTACTDETECTOR_H

#include "box2d/Box2D.h"

class b2ContactDetector : public b2ContactListener
{
public:
	void Add(const b2ContactPoint* point);
	void Persist(const b2ContactPoint* point);
	void Remove(const b2ContactPoint* point);
};
#endif