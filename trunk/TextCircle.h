//
//  TextCircle.h
//  Finger
//
//  Created by Mood on 9/14/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"
#import "LabeledInteractor.h"

#import <OpenGL/glu.h>

#ifdef __cplusplus
#import <FTGL/ftgl.h>
#endif

@interface TextCircle : EffectProvider <EffectProviderProtocol>
{	
	NSMutableArray *strings;
	NSMutableDictionary *deadStrings;
	NSMutableArray *stringsForRemoval;
	
#ifdef __cplusplus
	FTGLPolygonFont *font;
#endif
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;

@end
