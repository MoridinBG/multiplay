//
//  BaseTouchConnectionProvider.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"
#import "InteractiveObject.h"

#import "Logger.h"
#import "PointObj.h"
#import "ProximitySensorProtocol.h"

#ifdef __cplusplus
	#import "b2Physics.h"
	#import "b2ContactDetector.h"
#endif

@interface BaseTouchConnectionProvider : EffectProvider <EffectProviderProtocol, ProximitySensorProtocol> 
{
#ifdef __cplusplus
	b2ContactDetector *detector;
#endif
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;
@end
