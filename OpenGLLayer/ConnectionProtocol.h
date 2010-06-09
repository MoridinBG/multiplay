//
//  ConnectionProtocol.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 6/7/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol ConnectionProtocol

- (id) initWithendA:(InteractiveObject*) endA
			   endB:(InteractiveObject*) endB
		beginningAt:(float) beginnning
		   endingAt:(float)ending;

-(void) render;

@end
