//
//  SingletonVars.m
//  Finger
//
//  Created by Ivan Dilchovski on 11/16/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "SingletonVars.h"

@implementation SingletonVars
@synthesize sinArray;
@synthesize cosArray;

+ (SingletonVars*) instance
{
	static SingletonVars *myInstance;
	if(!myInstance)
		myInstance = [[SingletonVars alloc] init];
	
	return myInstance;
}

+ (CGPoint) calculateEndPointFromStart:(CGPoint)start withlength:(float)length andAngle:(float)angle
{
}

+ (float) calculateLengthBetweenStart:(CGPoint)start andEnd:(CGPoint)end
{
}

@end
