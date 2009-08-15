//
//  TouchSpot.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/4/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TouchSpot : NSObject
{
	float scale;
	float angle;
	float delta;
	CGPoint position;
	bool isScaling;
	bool isNew;
}
@property float scale;
@property float angle;
@property float delta;
@property bool isScaling;
@property CGPoint position;
@property bool isNew;

- (id) initWithPos:(CGPoint) pos;
- (void) setParameters:(CGPoint) position_ scale:(float) scale_ angle:(float) angle_ isScaling:(bool) isScaling_;

@end
