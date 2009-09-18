//
//  TextRender.h
//  Finger
//
//  Created by Mood on 9/14/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "EffectProvider.h"
#import "EffectProviderProtocol.h"

#import <OpenGL/glu.h>
#import <GL/glc.h>

@interface TextRender : EffectProvider <EffectProviderProtocol>
{	
	NSMutableArray *strings;
	GLfloat baseline[4];
}

- (id) init;
- (void) processTouches:(TouchEvent*)event;
- (void) render;

@end
