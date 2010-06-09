//
//  GLBackgroundLayer.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 3/29/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "consts.h"


@interface GLBackgroundLayer : CAOpenGLLayer 
{
	CGLContextObj _localContext;
}

@end
