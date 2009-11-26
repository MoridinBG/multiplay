//
//  GeometricObject.m
//  Finger
//
//  Created by Ivan Dilchovski on 11/21/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "GeometricObject.h"

@implementation GeometricObject
@synthesize type;
@synthesize numVertices;

@synthesize vertices;
@synthesize colors;

- (id) initWithPosition:(CGPoint)position type:(GLenum)type vertices:(CGPoint*)vertices andNumVertices:(int) numVertices
{
	if(self = [super initWithPos:position])
	{
		self.type = type;
		self.vertices = vertices;
		self.numVertices = numVertices;
	}
	
	return self;
}
- (void) render
{
	RGBA color;
	
	glTranslated(position.x, position.y, 0.f);
	glBegin(type);
	for(int i = 0; i < numVertices; i++)
	{
		if(colors)
			color = colors[i];
		else
		{
			color.r = 0.f;
			color.g = 1.f;
			color.b = 0.f;
		}
		glColor3f(color.r, color.g, color.b);

		glVertex2f(vertices[i].x, 
				   vertices[i].y);
	}
	glEnd();
	glTranslated(-(position.x), -(position.y), 0.f);
}

@end
