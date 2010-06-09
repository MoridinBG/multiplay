//
//  ObjectPoint.h
//  TUIO
//
//  Created by Ivan Dilchovski on 3/27/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ObjectPoint : NSObject 
{
	float _x, _y;
}

- (id) initWithX:(float)x Y:(float)y;
- (id) initWithCGPoint:(CGPoint)point;

- (CGPoint) getCGPoint;

@property float x;
@property float y;

@end
