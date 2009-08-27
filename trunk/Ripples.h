//
//  Ripples.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/31/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/glu.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import "InteractiveObject.h"

#import "Logger.h"

@interface Ripples : EffectProvider <EffectProviderProtocol> 
{
	NSMutableDictionary *ripples;				//Store ripples for still present touches
	NSMutableDictionary *dieingRipples;			//Store ripples for removed touches until animated out
	NSMutableArray *deadRipples;				//We can't modify a container, while enumerating, so temporary put finally dead ripples here
	
	float rot;
	
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;
@end
