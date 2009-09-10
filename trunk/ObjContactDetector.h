//
//  ObjContactDetector.h
//  Finger
//
//  Created by Mood on 8/28/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
	#import "b2ContactDetector.h"
#endif

@interface ObjContactDetector : NSObject 
{
#ifdef __cplusplus
	b2ContactDetector *detector;
#endif
}

#ifdef __cplusplus
	@property (readonly) b2ContactDetector *detector;
#endif

- (id) init;

- (void) contactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;
- (void) updateContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;
- (void) removeContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;

@end
