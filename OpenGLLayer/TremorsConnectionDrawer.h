//
//  TremorsConnectionDrawer.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/23/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#define LINES 4
#define LINES_DISTANCE 0.03f

#import <Cocoa/Cocoa.h>
#import "Connection.h"
#import "AlphaChangeContainer.h"

@interface TremorsConnectionDrawer : Connection
{
	AlphaChangeContainer *lines[LINES];
}

- (id) initWithendA:(InteractiveObject*) endA
			   endB:(InteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float) ending;

-(void) render;

@end
