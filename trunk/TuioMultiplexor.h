//
//  TuioMultiplexor.h
//  Finger
//
//  Created by Mood on 9/2/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TouchEvent.h"
#import "Logger.h"
#import "EffectProviderProtocol.h"

@class EffectProvider;
@interface TuioMultiplexor : NSObject 
{
	EffectProvider <EffectProviderProtocol> *provider;
	int numSenders;
	float ratio;
	NSSize dimensions;
	NSRecursiveLock *lock;
}

@property (assign) EffectProvider *provider;

- (id) init;

- (CGPoint) transformCoordinates:(CGPoint)pos forPortOffset:(int) offset;
- (void) setDimensions:(NSSize) dimensions_;

- (void) cursorAddedEvent: (TouchEvent*) newEvent;
- (void) cursorUpdatedEvent: (TouchEvent*) updatedEvent;
- (void) cursorRemovedEvent: (TouchEvent*) removedEvent;

- (long) calculateOffset:(long) uid;

@end
