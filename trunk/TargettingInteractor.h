//
//  ConnectableInteractor.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/4/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//
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
	int startPositionOnTrajectory;
	int endPositionOnTrajectory;	
	
	float curving;
	float controlPointDistance;
	
	bool isAimless;
}
@property (copy) NSNumber *origin;
@property (copy) NSNumber *target;

@property CGPoint targetCache;
@property CGPoint originCache;

@property RGBA targetColorCache;
@property RGBA originColorCache;

@property NSMutableArray *trajectory;
@property int startPositionOnTrajectory;
@property int endPositionOnTrajectory;

@property bool isAimless;

@property float curving;
@property float controlPointDistance;

- (id) initWithOrigin:(NSNumber*) aOrigin target:(NSNumber*) aTarget;

- (void) calculateBezierTrajectoryWithStart:(CGPoint)start andEnd:(CGPoint)end;
@end
