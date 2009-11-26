//
//  GeometricObject.h
//  Finger
//
//  Created by Ivan Dilchovski on 11/21/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InteractiveObject.h"


@interface GeometricObject : InteractiveObject 
{
	GLenum type;
	int numVertices;
	
	CGPoint *vertices;
	RGBA *colors;
}
@property GLenum type;
@property int numVertices;

@property CGPoint *vertices;
@property RGBA *colors;

- (id) initWithPosition:(CGPoint)position type:(GLenum)type vertices:(CGPoint*)vertices andNumVertices:(int) numVerticees;
- (void) render;

@end
