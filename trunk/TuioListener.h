//
//  TuioCursor.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/21/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TUIO/TuioClient.h>

#import "TouchEvent.h"
#import "TuioMultiplexor.h"

@class EffectProvider;
@interface TuioListener : NSObject <TuioCursorListener, TuioObjectListener>
{
	TuioClient *tuioClient;
	TuioMultiplexor *multiplexor;
	
	NSMutableDictionary *cursors;
	NSSize dimensions;
	float ratio;
}
@property TuioMultiplexor *multiplexor;

- (id) init;

- (void) tuioCursorAdded: (TuioCursor*) newCursor;
- (void) tuioCursorUpdated: (TuioCursor*) updatedCursor;
- (void) tuioCursorRemoved: (TuioCursor*) deadCursor;
- (void) tuioCursorFrameFinished;

- (void) tuioObjectAdded: (TuioObject*) newObject;
- (void) tuioObjectUpdated: (TuioObject*) updateObject;
- (void) tuioObjectRemoved: (TuioObject*) deadObject;
@end
