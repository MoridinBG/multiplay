//
//  b2Physics.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
	#import "box2d/Box2D.h"
	#import "b2ContactDetector.h"
#endif

@interface b2Physics : NSObject 
{
#ifdef __cplusplus
	b2World *world;
#endif
	
	NSLock *mutex;
}
- (void) main;
- (void) step:(NSTimer*) theTimer;

#ifdef __cplusplus
- (void) setContactListener:(b2ContactDetector*) detector;
- (b2Body*) addContactDetectorAtX:(float) x Y:(float) y;
#endif
@end
