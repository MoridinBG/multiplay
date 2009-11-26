//
//  PacMan.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/25/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import "InteractiveObject.h"

#import "Logger.h"

@interface PacMan : EffectProvider <EffectProviderProtocol> 
{

}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;

@end
