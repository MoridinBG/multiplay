//
//  Balls.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/15/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GLContentLayer.h"
#import "b2Physics.h"

@interface Balls : GLContentLayer
{
	b2Physics *physics;
	
	NSMutableArray *sludges;
	NSMutableDictionary *touches;
}
- (id) init;
- (void) setBounds:(CGRect)bounds;

- (void) addBlurFilter;
- (void) addBlob;
- (void) drawGL;

- (void) tuioBoundsAdded: (TuioBounds*) newBounds;
- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds;
- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds;

@end
