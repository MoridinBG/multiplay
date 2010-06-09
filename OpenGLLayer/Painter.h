//
//  Painter.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/4/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GLContentLayer.h"

@interface Painter : GLContentLayer
{
	id prevContents;
	
	GLuint textureId;
	GLuint rboId;
	GLuint fboId;
}
- (id) init;
- (void) addBlurFilter;
- (void) drawGL;
@end
