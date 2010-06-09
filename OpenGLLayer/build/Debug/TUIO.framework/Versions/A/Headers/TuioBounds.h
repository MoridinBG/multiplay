//
//  TuioBounds.h
//  TUIO
//
//  Created by Ivan Dilchovski on 4/7/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TuioContainer.h"
#import "gpc.h"


@interface TuioBounds : TuioContainer
{
	float _angle;
	CGSize _dimensions;
	float _area;
	float _rotVelocity;
	float _rotAccel;
	gpc_polygon _totalEverArea;
}
@property float angle;
@property CGSize dimensions;
@property float area;
@property float rotVelocity;
@property float rotAccel;
@property gpc_polygon totalEverArea;

- (id) initWithID:(unsigned int)sID
		 position:(CGPoint)pos
			angle:(float)angle
	   dimensions:(CGSize)dimensions
			 area:(float)area
 movementVelocity:(CGPoint)moveVelocity
	movementAccel:(float)moveAccel
 rotationVelocity:(float)rotVelocity
	rotationAccel:(float)rotAccel
		   atTime:(uint64_t)time;

- (void) setContour:(NSMutableArray *)contour;

@end
