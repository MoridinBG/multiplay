//
//  SparklesPhysics.h
//  Finger
//
//  Created by Mood on 7/28/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Physics.h"


@interface SparklesPhysics : Physics
{
	NSMutableDictionary *positions;			//Base position for given TouchID
	NSMutableDictionary *timers;			//Timers creating bodies around touches
	NSMutableDictionary *bodies;			//Groups of bodies associated with TouchIDs
	
#ifdef __cplusplus
	btCollisionShape* colShape;
	btDefaultMotionState* myMotionState;
	btScalar	mass;	
	btVector3 localInertia;
#endif
}

- (void) main;

- (NSMutableDictionary*) getPositions;

- (void) setPosition:(LiteTouchInfo) touch;
- (void) removePosition:(NSNumber*) uid;
@end
