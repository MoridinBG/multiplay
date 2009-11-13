//
//  ConnectableInteractor.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/4/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#define CONTROL_POINT_DISTANCE 0.5f
#define CURVING 0.2f

#import <Cocoa/Cocoa.h>
#import "InteractiveObject.h"
#import "LiteTouchInfo.h"
#import "PointObj.h"

@interface TargettingInteractor : InteractiveObject
{
	NSNumber *origin;
	NSNumber *target;
	CGPoint targetCache;
	CGPoint originCache;
	
	RGBA targetColorCache;
	RGBA originColorCache;
	
	NSMutableArray *trajectory;
	float positionOnTrajectory;
	
	bool isAimless;
}
@property (copy) NSNumber *origin;
@property (copy) NSNumber *target;

@property CGPoint targetCache;
@property CGPoint originCache;

@property RGBA targetColorCache;
@property RGBA originColorCache;

@property NSMutableArray *trajectory;
@property float positionOnTrajectory;

@property bool isAimless;

- (id) initWithOrigin:(NSNumber*) aOrigin target:(NSNumber*) aTarget;

- (void) calculateBezierTrajectoryWithStart:(CGPoint)start andEnd:(CGPoint)end;
@end
