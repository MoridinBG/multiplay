//
//  LightningConnection.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 6/7/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//
#define ARCS 10
#import <Cocoa/Cocoa.h>

#import "Connection.h"
#import "GlobalFunctions.h"
#import "AlphaChangeContainer.h"

#import "consts.h"

@interface LightningConnection : Connection
{
	GLuint displayLists[ARCS];
	AlphaChangeContainer *arcs[ARCS];
}

- (id) initWithendA:(InteractiveObject*) endA
			   endB:(InteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float) ending;

- (void) generateArcAt:(int) index;
- (void) render;

@end
