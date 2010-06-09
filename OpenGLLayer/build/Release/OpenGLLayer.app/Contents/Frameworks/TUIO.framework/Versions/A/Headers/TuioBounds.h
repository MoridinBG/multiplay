//
//  TuioBounds.h
//  TUIO
//
//  Created by Ivan Dilchovski on 4/7/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TuioContainer.h"


@interface TuioBounds : TuioContainer
{
	float _angle;
	CGSize _dimensions;
	float _area;
	float _rotSpeed;
	float _rotAccel;
}
@property float angle;
@property CGSize dimensions;
@property float area;
@property float rotSpeed;
@property float rotAccel;

- (id) initWithID:(unsigned int)sID
		 position:(CGPoint)pos
			angle:(float)angle
	   dimensions:(CGSize)dimensions
			 area:(float)area
	movementSpeed:(CGPoint)moveSpeed
	movementAccel:(float)moveAccel
	rotationSpeed:(float)rotSpeed
	rotationAccel:(float)rotAccel;

@end
