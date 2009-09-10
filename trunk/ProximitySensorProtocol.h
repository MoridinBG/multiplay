/*
 *  ProximitySensorProtocol.h
 *  Finger
 *
 *  Created by Mood on 9/5/09.
 *  Copyright 2009 The Pixel Factory. All rights reserved.
 *
 */

@protocol ProximitySensorProtocol

- (void) contactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;
- (void) updateContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;
- (void) removeContactBetween:(NSNumber*) firstID And:(NSNumber*) secondID;

@end