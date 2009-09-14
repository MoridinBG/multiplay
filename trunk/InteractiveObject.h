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
@interface InteractiveObject : NSObject
{
	float scale;
	float angle;
	float delta;
	CGPoint position;
	bool isScaling;
	bool isNew;
	bool isHolding;
	
	NSMutableArray *neighbours;
	NSMutableDictionary *connectedNeighbours;
	void *physicsData;
	
	RGBA color;
	RGBA newColor;
	RGBA colorStep;
}

@property float scale;
@property float angle;
@property float delta;
@property CGPoint position;
@property bool isScaling;
@property bool isNew;
@property bool isHolding;
@property RGBA color;

@property void *physicsData;

- (id) initWithPos:(CGPoint) pos;
- (void) setParameters:(CGPoint) position_ scale:(float) scale_ angle:(float) angle_ isScaling:(bool) isScaling_;

- (void) addNeighbour:(NSNumber*) uid;
- (void) removeNeighbour:(NSNumber*) uid;
- (NSArray*) getNeighbours;

- (void) addNeighbour:(NSNumber*) uid withConnection:(TargettingInteractor*) connection;
- (TargettingInteractor*) removeConnectedNeighbour:(NSNumber*) uid;
- (bool) hasConnectedNeighbour:(NSNumber*) neighbour;

- (int) connectedNeighboursCount;

- (void) setColor:(RGBA) aColor;
- (void) randomizeColor;

@end

