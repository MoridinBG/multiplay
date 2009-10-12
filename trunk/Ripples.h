//
//  Ripples.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/31/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import "ClusteredInteractor.h"

#import "Logger.h"

@interface Ripples : EffectProvider <EffectProviderProtocol> 
{
	NSMutableDictionary *dieingTouches;
	NSMutableArray *deadTouches;
	NSMutableDictionary *newTouches;
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;
@end
