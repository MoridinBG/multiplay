//
//  TuioClient.h
//  TUIO
//
//  Created by Bridger Maxwell on 1/3/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//
//	Modified by Ivan Dilchovski on 24.03.2010.

#import <Cocoa/Cocoa.h>
#import <netinet/in.h>
#import <net/if.h>
#include <mach/mach_time.h>

#import "WSOSCPacket.h"
#import "TuioBounds.h"


@protocol TuioBoundsListener
- (void) tuioBoundsAdded: (TuioBounds*) newBounds;
- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds;
- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds;
- (void) tuioFrameFinished;
@end

@interface TuioClient : NSObject 
{
	NSFileHandle* fileHandle;
	CFSocketRef cfSocket;
	CFRunLoopSourceRef cfSource;

	NSMutableDictionary* _liveBounds;
	NSMutableArray *_boundsDelegates;
	NSSize _delegateDimensions;
	
	unsigned long currentFrameTime;
	
	float minCCVX, maxCCVX;
	float aspect;
}

@property(assign) NSMutableArray *boundsDelegates;

- (id)initWithPortNumber:(int)portNumber andDelegateDimensions:(NSSize) dimensions;
- (void)finalize;
- (void) processOSCMessage: (NSNotification *)notification;
- (void) processOSCBundle: (NSNotification *)notification;
- (CGPoint) calibratedPoint:(CGPoint) point;
- (CGPoint) calibratedContourPoint:(CGPoint) point;

- (void) reload;

static void socketCallback(CFSocketRef cfSocket, CFSocketCallBackType
						   type, CFDataRef address, const void *data, void *userInfo);

@end
