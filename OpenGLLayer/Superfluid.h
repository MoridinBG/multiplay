//
//  Superfluid.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/21/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#define MESH_SIZE 200
#define TIME_STEP 1.5f
#define VISCOSITY 0.003f

#define IS_WIREFRAME false

#import <Cocoa/Cocoa.h>
#import "GLContentLayer.h"
#import "Fluid2D.h"

@interface Superfluid : GLContentLayer
{
	Fluid2D *fluid;
	
	NSOperationQueue *operationQueue;
}
- (id) init;
- (void) finalize;

- (CGPoint) calibratePoint:(CGPoint)point;
- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds;

- (void) addBlurFilter;
- (void) drawGL;

@end
