//
//  InteractiveObject.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "consts.h"

@class TargettingInteractor;
@interface InteractiveObject : NSObject <NSCopying>
{
	float scale;
	float delta;
	float targetScale;
	
	CGPoint position;
	CGPoint lastFramePosition;
	int framesStatic;
	CGPoint direction;
	
	NSMutableArray *positionHistoryQueue;
	int historyDepth;
	
	bool isScaling;
	bool isNew;
	
	int itemsHeld;
	bool isHolding;
	
	float angle;
	float rotateDelta;
	bool rotateLeft;
	
	void *physicsData;
	NSTimer *timer;
	RGBA color;
	
	NSMutableArray *neighbours;
	NSMutableDictionary *connectedNeighbours;
	
	RGBA newColor;
	RGBA colorStep;
	float colorSpeed;
	float alphaDelta;
}

@property (copy) NSMutableArray *neighbours;
@property (copy) NSMutableDictionary *connectedNeighbours;

@property RGBA newColor;
@property RGBA colorStep;
@property float colorSpeed;
@property float alphaDelta;


@property float scale;
@property float delta;
@property float targetScale;

@property CGPoint position;
@property CGPoint lastFramePosition;
@property int framesStatic;
@property CGPoint direction;

@property NSMutableArray *positionHistoryQueue;
@property int historyDepth;

@property bool isScaling;
@property bool isNew;

@property int itemsHeld;
@property bool isHolding;

@property float angle;
@property float rotateDelta;
@property bool rotateLeft;

@property void *physicsData;
@property NSTimer *timer;
@property RGBA color;

- (id) initWithPos:(CGPoint) pos;
- (id) copyWithZone:(NSZone *) zone;

- (void) setAngle:(float) newAngle;

- (void) render;

- (void) addNeighbour:(NSNumber*) uid;
- (void) removeNeighbour:(NSNumber*) uid;
- (NSArray*) getNeighbours;
- (bool) hasNeighbour:(NSNumber*) uid;
- (int) neighboursCount;

- (void) addNeighbour:(NSNumber*) uid withConnection:(TargettingInteractor*) connection;
- (TargettingInteractor*) removeConnectedNeighbour:(NSNumber*) uid;
- (bool) hasConnectedNeighbour:(NSNumber*) neighbour;
- (NSArray*) getConnectedNeighbours;
- (int) connectedNeighboursCount;

- (void) setColor:(RGBA) aColor;
- (void) setRandomColor;
- (void) randomizeColor;
- (void) stepColors;
@end

