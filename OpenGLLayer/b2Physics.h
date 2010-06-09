//
//  b2Physics.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/15/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include <CoreServices/CoreServices.h>
#import <mach/mach_time.h>

#ifdef __cplusplus
	#import "Box2D.h"
	#import "Render.h"
	#import "ConstantVolumeJoint.h"
#endif

#import "GlobalFunctions.h"
#import "InteractiveObject.h"
#import "ContactDetector.h"

@interface b2Physics : NSObject 
{
#ifdef __cplusplus
	b2World *world;
	b2Body *_groundBody;
	DebugDraw debugDraw;
#endif
	NSOperationQueue *operationQueue;

	float timeStep;
	int velocityIterations;
	int positionIterations;
	
	NSMutableDictionary *mouseJoints;
}

- (id) init;
- (void) createGroundWithDimensions:(CGSize)dimensions;
- (void) step;
- (ContactDetector *) addContactDetector;

#pragma mark Create/Destroy Bodies
- (InteractiveObject*) createPolygonBodyAtPosition:(CGPoint)position withSize:(CGSize)size rotatedAt:(float)angle;
- (InteractiveObject*) createCircleBodyAtPosition:(CGPoint)position withSize:(CGSize)size;
- (InteractiveObject*) createCircleSensorAtPosition:(CGPoint)position
										   withSize:(CGSize)size;
- (void) destroyBody:(NSValue*)packedBody;
#pragma mark -

#pragma mark Create/Destroy Mouse Joints
- (void) attachMouseJointToBody:(NSValue*)body withId:(NSNumber*)uid;
- (void) detachMouseJointWithId:(NSNumber*)uid;
- (void) updateMouseJointWithId:(NSNumber*)uid toPosition:(CGPoint)position;
#pragma mark -

- (NSMutableArray *) createBlobAt:(CGPoint)position 
					   withRadius:(float) blobRadius;
@end
