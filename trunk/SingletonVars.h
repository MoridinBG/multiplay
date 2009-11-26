//
//  SingletonVars.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/16/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SingletonVars : NSObject 
{
	float *sinArray;
	float *cosArray;
}
@property float *sinArray;
@property float *cosArray;

+ (SingletonVars*) instance;

+ (CGPoint) calculateEndPointFromStart:(CGPoint)start withlength:(float)length andAngle:(float)angle;
+ (float) calculateLengthBetweenStart:(CGPoint)start andEnd:(CGPoint)end;
@end
