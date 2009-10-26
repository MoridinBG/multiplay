//
//  b2Physics.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
	#import "box2d/Box2D.h"
	#import "b2ContactDetector.h"
	#import "Render.h"
#endif
#import "consts.h"

@interface b2Physics : NSObject 
{
#ifdef __cplusplus
	b2World *world;
	b2Body *frame;
	DebugDraw debugDraw;
#endif	
}
- (id) initWithDimensions:(CGSize) dimensions withFrame:(bool) frame;
- (void) createFrameWithDimensions:(CGSize) dimensions;
- (void) step;

#ifdef __cplusplus
- (b2ContactDetector*) addContactDetector;
- (b2Body*) addProximityContactListenerAtX:(float)x Y:(float)y withUid:(NSNumber*)uid;

- (void*) createRectangularBodyWithSize:(CGSize)size atPosition:(CGPoint)position;
- (void) destroyBody:(b2Body*) body;
- (CGPoint) getCoordinatesFromBody:(b2Body*) body;
#endif

@end
