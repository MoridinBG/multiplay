//
//  TouchEvent.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/16/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "consts.h"

@interface TouchEvent : NSObject 
{
	NSNumber *uid;
	CGPoint pos;
	CGPoint lastPos;
	CGPoint touchDownPos;
	float speed;
	TouchType type;
	bool ignoreEvent;
}

@property (copy) NSNumber *uid;
@property CGPoint pos;
@property CGPoint lastPos;
@property CGPoint touchDownPos;
@property float speed;
@property TouchType type;
@property bool ignoreEvent;

- (id) initWithId:(NSNumber*)aUid withType:(TouchType)aType atPos:(CGPoint)aPos;
- (void) setPos:(CGPoint) newPos;

@end
