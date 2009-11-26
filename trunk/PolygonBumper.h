//
//  PolygonBumper.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/20/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//
#define MAX_POLYGONS 30
#define MAX_POLYGON_VERTICES 8
#define MAX_ACTIVE_POLYGONS 15
#define MAX_POLYGON_RADIUS 8
#define MIN_POLYGON_RADIUS 4
#define DISAPPEAR_SCALE 0.05f

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import "GeometricObject.h"

#import "Logger.h"

#ifdef __cplusplus
	#import "b2Physics.h"
	#import "b2ContactDetector.h"
#endif

@interface PolygonBumper : EffectProvider <EffectProviderProtocol>
{
	NSTimer *polygonCreator;
	NSMutableArray *polygons;
	NSMutableArray *dieingPolygons;
	NSMutableArray *deadPolygons;
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;

- (void) createPolygon:(NSTimer*) theTimer;
- (void) removePolygon:(NSTimer*) theTimer;
@end
