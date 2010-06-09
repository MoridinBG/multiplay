//
//  ContactDetector.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/20/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProximitySensorListener.h"

#ifdef __cplusplus
#import "b2ContactDetector.h"
#endif

@interface ContactDetector : NSObject <ProximitySensorListener>
{
	id<ProximitySensorListener> _effect;
	
#ifdef __cplusplus
	b2ContactDetector *_box2DContactDetector;
#endif
}
@property id effect;
#ifdef __cplusplus
@property(readonly) b2ContactDetector *box2DContactDetector;
#endif

- (id) init;

- (void) contactBetween:(InteractiveObject*)firstObj And:(InteractiveObject*)secondObj;
- (void) removedContactBetween:(InteractiveObject*)firstObj And:(InteractiveObject*)secondObj;
@end
