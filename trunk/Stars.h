//
//  Stars.h
//  Finger
//
//  Created by Ivan Dilchovski on 7/31/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import "InteractiveObject.h"

#import "Logger.h"

@interface Stars : EffectProvider <EffectProviderProtocol> 
{
	NSMutableDictionary *stars;						//Store stars for still present touches
	NSMutableDictionary *dieingStars;				//Store stars for removed touches until animated out
	NSMutableArray *deadStars;						//We can't modify a container, while enumerating, so temporary put finally dead stars here
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;
@end
