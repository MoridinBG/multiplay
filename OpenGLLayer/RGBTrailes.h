//
//  RGBTrailes.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLContentLayer.h"

#define CONTOURS_BACK 5

@interface RGBTrailes : GLContentLayer
{
}

- (id) init;
- (void) addBlurFilter;
- (void) drawGL;

@end
