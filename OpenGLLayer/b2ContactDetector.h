//
//  b2ContactDetector.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/20/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//
#import <Box2D.h>
#import "ProximitySensorListener.h"

class b2ContactDetector : public b2ContactListener
{
public:
	b2ContactDetector(id objectiveBridge);
	void BeginContact(b2Contact *contact);
	void EndContact(b2Contact *contact);
	
	id<ProximitySensorListener> _objectiveBridge;
};