//
//  LineConnect.h
//  Finger
//
//  Created by Ivan Dilchovski on 9/4/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <math.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"
#import "ProximitySensorProtocol.h"

#import "Logger.h"

#ifdef __cplusplus
	#import "b2Physics.h"
	#import "b2ContactDetector.h"
#endif

@interface LineConnect : EffectProvider <EffectProviderProtocol, ProximitySensorProtocol>
{	
#ifdef __cplusplus
	b2ContactDetector *detector;
#endif
	
	NSMutableArray *connections;
	NSMutableArray *dieingConnections;
	NSMutableArray *deadConnections;
	
	NSMutableArray *dieingSpots;
	NSMutableArray *deadSpots;
	
	float radius;
	float subStep;
	
	float alpha;
	float alphaStep;
}
- (id) init;
- (void) createVertexArray;

- (void) processTouches:(TouchEvent*)event;
- (void) render;

@end
