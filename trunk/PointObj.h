//
//  PointObj.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/5/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PointObj : NSObject 
{
	float x;
	float y;
}
@property float x;
@property float y;

- (id) initWithPoint:(CGPoint) point;
- (id) initWithX:(float)x Y:(float)y;

- (CGPoint) getCGPoint;

@end
