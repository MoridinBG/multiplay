//
//  TextCircle.h
//  Finger
//
//  Created by Mood on 9/14/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#define TEXT_TARGET_DELTA 2.f
#define TEXT_TARGET_DELTA_STEP 4.f
#define TEXT_TARGET_ROTATE_DELTA 34.f
#define TEXT_TARGET_ROTATE_DELTA_STEP 2.f
#define TEXT_START_ROTATE_DELTA 60.f

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"
#import "LabeledInteractor.h"

#import <OpenGL/glu.h>

#ifdef __cplusplus
#import <FTGL/ftgl.h>
#import <FTGL/FTGLPolygonFont.h>
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
