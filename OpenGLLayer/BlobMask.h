//
//  BlobMask.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GLContentLayer.h"

@interface BlobMask : GLContentLayer
{

}
- (id) init;
- (void) addBlurFilter;
- (void) drawGL;
@end
