/*
 *  ProximitySensorProtocol.h
 *  Finger
 *
 *  Created by Mood on 9/5/09.
 *  Copyright 2009 The Pixel Factory. All rights reserved.
 *
 */

#import "InteractiveObject.h"

@protocol ProximitySensorListener

- (void) contactBetween:(InteractiveObject*)firstObj And:(InteractiveObject*)secondObj;
- (void) removedContactBetween:(InteractiveObject*)firstObj And:(InteractiveObject*)secondObj;

@end