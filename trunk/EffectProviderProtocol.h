/*
 *  EffectProviderProtocol.h
 *  Finger
 *
 *  Created by Mood on 7/27/09.
 *  Copyright 2009 The Pixel Factory. All rights reserved.
 *
 */

@protocol EffectProviderProtocol

- (void) processTouches:(TouchEvent*) event;
- (void)render;

@end