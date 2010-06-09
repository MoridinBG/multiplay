//
//  BlobMask.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BlobMask.h"


@implementation BlobMask

- (id) init
{
	if(self = [super init])
	{
//		[self addBlurFilter];
	}
	return self;
}

- (void) addBlurFilter
{
	CIFilter *blur = [CIFilter filterWithName:@"CIDiscBlur"];
	[blur setDefaults];
	[blur setValue:[NSNumber numberWithFloat:20.f] forKey:@"inputRadius"];
	blur.name = @"blur";
	[self setFilters:[NSArray arrayWithObjects:blur, nil]];
}

- (void) drawGL
{
	NSArray *keys = [objects allKeys];
	NSNumber *key;
	InteractiveObject *object;
	RGBA *color;
	for(key in keys)
	{
		object = [objects objectForKey:key];
		color = [objectColors objectForKey:key];
		
		glColor4f(0.f,
				  0.f,
				  0.f,
				  1.f);
		gluTessBeginPolygon(tess, NULL);
		gluTessBeginContour(tess);
		
		NSArray *contour = object.points;
		int count = [contour count];
		GLdouble vertices[count][3];
		for(int i = 0; i < count; i++)
		{
			ObjectPoint *point = [contour objectAtIndex:i];
			vertices[i][0] = point.x;
			vertices[i][1] = point.y;
			vertices[i][2] = 0.f;
			gluTessVertex(tess, vertices[i], vertices[i]);
		}
		
		gluTessEndContour(tess);
		gluTessEndPolygon(tess);
		
		glColor3f(1.f,
				  1.f,
				  1.f);
		
		glTranslatef(object.position.x, object.position.y, 0.f);
		glRotatef(object.angle, 0.f, 0.f, 1.f);
		glTranslatef(-object.position.x, -object.position.y, 0.f);
		
		glBegin(GL_LINE_LOOP);
		glVertex2f(object.position.x - object.size.width / 2,
					object.position.y - object.size.height / 2);
		glVertex2f(object.position.x + object.size.width / 2,
					object.position.y - object.size.height / 2);
		glVertex2f(object.position.x + object.size.width / 2,
					object.position.y + object.size.height / 2);
		glVertex2f(object.position.x - object.size.width / 2,
					object.position.y + object.size.height / 2);
		glEnd();
		glLoadIdentity();
	}
}

@end
