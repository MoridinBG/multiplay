//
//  SineWalker.h
//  Finger
//
//  Created by Ivan Dilchovski on 8/23/09.
//  Copyright 2009 The Pixel Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ConnectableInteractor.h"


@interface SineWalker : NSThread 
{
	NSMutableDictionary *sines;
	NSLock *mutex;
}
- (void) step:(NSTimer*) theTimer;
- (void) main;
- (void) addSine:(ConnectableInteractor*) sine withUid:(NSNumber*) uid;
- (NSNumber*) targetForSine:(NSNumber*) uid;
- (NSDictionary*) getSines;
@end
