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
#define HISTORY_DEPTH 100

@interface TuioContainer : NSObject 
{
	unsigned int _sID;
	CGPoint _position;
	CGPoint _moveSpeed;
	float _moveAccel;
	TouchType _state;
	
	NSMutableArray *_contour;
	NSMutableArray *_movementHistory;
	NSMutableArray *_contourHistory;
}

- (id) initWithID:(unsigned int)sID 
		 position:(CGPoint)pos
	movementSpeed:(CGPoint)moveSpeed
	movementAccel:(float)moveAccel;

- (void) setContour:(NSMutableArray *)contour;
- (void) setPosition:(CGPoint)position;
- (NSNumber*) getKey;

@property (readonly) unsigned int sessionID;
@property CGPoint position;
@property CGPoint movementSpeed;
@property float movementAccel;
@property TouchType state;

@property(assign) NSMutableArray *contour;
@property(assign) NSMutableArray *movementHistory;
@property(assign) NSMutableArray *contourHistory;

@end
