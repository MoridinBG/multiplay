//
//  RGBA.h
//  Finger
//
//  Created by Ivan Dilchovski on 12/27/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RGBA : NSObject 
{
	float _r;
	float _g;
	float _b;
	float _a;
}
@property float r;
@property float g;
@property float b;
@property float a;

- (id) initWithR:(float) r
		   withG:(float) g
		   withB:(float) b
		   withA:(float) a;

+ (id) randomColorWithMinimumValue:(int)minColor;

@end
