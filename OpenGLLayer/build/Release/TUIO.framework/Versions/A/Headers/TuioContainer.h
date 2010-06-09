//
//  TuioPointer.h
//  TUIO
//
//  Created by Bridger Maxwell on 2/16/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//
//	Modified by Ivan Dilchovski on 24.03.2010.

#import <Cocoa/Cocoa.h>
#import "TuioPoint.h"

typedef enum touchtype {TuioAdded, TuioUpdated, TuioRemoved} TouchType;
#define HISTORY_DEPTH 200

@interface TuioContainer : NSObject 
{
	unsigned int _sID;
	
	CGPoint _lastPosition;
	CGPoint _position;
	
	CGPoint _lastMoveVelocity;
	CGPoint _moveVelocity;
	float _moveAccel;
	
	TouchType _state;
	float _zPosition;
	
	NSMutableArray *_contour;
	NSMutableArray *_movementHistory;
	NSMutableArray *_contourHistory;
	
	uint64_t _updateTime;
	uint64_t _lastUpdateTime;
}

- (id) initWithID:(unsigned int)sID 
		 position:(CGPoint)pos
 movementVelocity:(CGPoint)moveVelocity
	movementAccel:(float)moveAccel
		   atTime:(uint64_t)time;

- (void) setContour:(NSMutableArray *)contour;
- (void) setPosition:(CGPoint)position;
- (void) setUpdateTime:(uint64_t)time;

- (NSNumber*) getKey;

@property (readonly) unsigned int sessionID;

@property CGPoint lastPosition;
@property CGPoint position;

@property CGPoint lastMovementVelocity;
@property CGPoint movementVelocity;
@property float movementAccel;

@property TouchType state;
@property float zPosition;

@property(assign) NSMutableArray *contour;
@property(assign) NSMutableArray *movementHistory;
@property(assign) NSMutableArray *contourHistory;

@property uint64_t updateTime;
@property uint64_t lastUpdateTime;

@end
