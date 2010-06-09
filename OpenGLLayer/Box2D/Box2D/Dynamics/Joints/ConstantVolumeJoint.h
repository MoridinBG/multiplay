/*
 *  ConstantVolumeJointDef.h
 *  Box2D
 *
 *  Created by Ivan Dilchovski on 5/18/10.
 *  Copyright 2010 Bulplex LTD. All rights reserved.
 *
 */

#include <vector>
#include <iostream>

#include "b2Joint.h"
#include "b2DistanceJoint.h"
#include "../b2World.h"
#include "../b2TimeStep.h"
#include "../b2Body.h"

struct ConstantVolumeJointDef : public b2JointDef
{
	std::vector<b2Body*> bodies;
	
	float frequencyHz;
	float dampingRatio;
	
	ConstantVolumeJointDef()
	{
		type = e_constantVolumeJoint;
		collideConnected = false;
		frequencyHz = 0.f;
		dampingRatio = 0.f;
	}
	
	void addBody(b2Body *body)
	{
		bodies.push_back(body);
		if(bodies.size() == 1)
			bodyA = body;
		if(bodies.size() == 2)
			bodyB = body;
	}
};

class ConstantVolumeJoint : public b2Joint
{
public:
	std::vector<b2Body*> getBodies();
	void Inflate(float factor);
	bool ConstrainEdges(b2TimeStep step);
	
	
	bool SolvePositionConstraints(float32 flt);
	virtual void InitVelocityConstraints(const b2TimeStep& step);
	virtual void SolveVelocityConstraints(const b2TimeStep& step);
	
	virtual b2Vec2 GetAnchorA() const;
	virtual b2Vec2 GetAnchorB() const;
	virtual b2Vec2 GetReactionForce(float32 inv_dt) const;
	virtual float32 GetReactionTorque(float32 inv_dt) const;
protected:
	friend class b2Joint;
	ConstantVolumeJoint(const ConstantVolumeJointDef *def);
	
	float GetArea();
	
	std::vector<b2Body*> bodies;
	std::vector<b2DistanceJoint*> distanceJoints;
	float *targetLengths;
	float targetVolume;
	float impulse;

	b2Vec2 *normals;
	b2Vec2 *d;
	float m_impulse;
	b2TimeStep m_step;
	
	b2World *world;
};