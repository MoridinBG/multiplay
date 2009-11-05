//
//  TouchSwap.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"
#import "InteractiveObject.h"

#import "Logger.h"

@interface TouchSwap : EffectProvider <EffectProviderProtocol> 
{
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;
@end
