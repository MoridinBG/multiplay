//
//  InteractiveObject.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/24/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface InteractiveObject : NSObject
{
	float scale;
	float angle;
	float delta;
	CGPoint position;
	bool isScaling;
	bool isNew;
	
	NSMutableArray *neighbours;
	void *physicsData;
}

@property float scale;
@property float angle;
@property float delta;
@property CGPoint position;
@property bool isScaling;
@property bool isNew;

@property void *physicsData;

- (id) initWithPos:(CGPoint) pos;
- (void) setParameters:(CGPoint) position_ scale:(float) scale_ angle:(float) angle_ isScaling:(bool) isScaling_;

- (void) addNeighbour:(NSNumber*) uid;
- (void) removeNeighbour:(NSNumber*) uid;
- (NSArray*) getNeighbours;

@end

