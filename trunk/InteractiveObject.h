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
	float delta;
	
	CGPoint position;
	CGPoint direction;
	
	bool isScaling;
	bool isNew;
	bool isHolding;
	
	float angle;
	float rotateDelta;
	bool rotateLeft;
	
	void *physicsData;
	RGBA color;
	
	NSMutableArray *neighbours;
	NSMutableDictionary *connectedNeighbours;
	
	RGBA newColor;
	RGBA colorStep;
}

@property (copy) NSMutableArray *neighbours;
@property (copy) NSMutableDictionary *connectedNeighbours;

@property RGBA newColor;
@property RGBA colorStep;

@property float scale;
@property float delta;

@property CGPoint position;
@property CGPoint direction;

@property bool isScaling;
@property bool isNew;
@property bool isHolding;


@property float angle;
@property float rotateDelta;
@property  bool rotateLeft;

@property void *physicsData;
@property RGBA color;

- (id) initWithPos:(CGPoint) pos;
- (void) setParameters:(CGPoint) position_ scale:(float) scale_ angle:(float) angle_ isScaling:(bool) isScaling_;

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
- (void) randomizeColor;
@end

