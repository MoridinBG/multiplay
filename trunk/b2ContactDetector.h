/*
 *  b2ContactDetector.h
 *  Finger
 *
 *  Created by Mood on 8/28/09.
 *  Copyright 2009 The Pixel Factory. All rights reserved.
 *
 */


#import "box2d/Box2D.h"
#import "ProximitySensorProtocol.h"

@class EffectProvider;
class b2ContactDetector : public b2ContactListener
{
public:
	b2ContactDetector();
	
	void Add(const b2ContactPoint* point);
	void Persist(const b2ContactPoint* point);
	void Remove(const b2ContactPoint* point);
	void Result(const b2ContactResult* point);
	void setProvider(EffectProvider <ProximitySensorProtocol> *provider);
	
	EffectProvider <ProximitySensorProtocol> *effectProvider;
};
