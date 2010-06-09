//
//  BoundariesBurn.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GLContentLayer.h"
#import "BlobMask.h"

@interface BoundariesBurn : GLContentLayer
{
}
- (id) init;
- (void) addBurningFilter;
- (void) drawGL;
@end
