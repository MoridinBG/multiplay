//
//  Stripes.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Stripes.h"
#import "GlobalFunctions.h"

@implementation Stripes

- (id) init
{
	if(self = [super init])
	{
/*
		CGPoint position = CGPointMake(0.5f, 0.5f);
		CGPoint velocity = CGPointMake(0.f, 0.f);
		
		CGSize size = CGSizeMake(0.45f, 0.3f);
		
		TuioBounds *blob = [[TuioBounds alloc] initWithID:1
												 position:position
													angle:45
											   dimensions:size
													 area:(size.width * size.height)
										 movementVelocity:velocity
											movementAccel:0.f
										 rotationVelocity:0.f
											rotationAccel:0.f
												   atTime:0];
		
		[blobs setObject:blob forKey:[blob getKey]];
//*/
	}
	return self;
}

- (void) drawGL
{
	NSArray *keys = [objects allKeys];
	NSNumber *key;
	TuioBounds *blob;
	RGBA *color;
	for(key in keys)
	{
		blob = [objects objectForKey:key];
//		color = [blobColors objectForKey:key];
		color = [RGBA randomColorWithMinimumValue:40];
		
		CGPoint position = blob.position;
		CGSize size = blob.dimensions;
		
//		NSLog(@"%f, %f  %f, %f, %f", position.x, position.y, size.width, size.height, blob.angle);

		glColor3f(color.r,
				  color.g,
				  color.b);
		glColor3f(1.f, 0.f, 1.f);

//*
		glLoadIdentity();
		glTranslated(position.x, position.y, 0.f);
		glRotated(blob.angle, 0.f, 0.f, 1.f);
		glTranslated(-position.x, -position.y, 0.f);
		
		glBegin(GL_LINE_LOOP);
		glVertex2f(position.x - (size.width / 2),
				   position.y - (size.height / 2));
		glVertex2f(position.x + (size.width / 2),
				   position.y - (size.height / 2));
		glVertex2f(position.x + (size.width / 2),
				   position.y + (size.height / 2));
		glVertex2f(position.x - (size.width / 2),
				   position.y + (size.height / 2));
		glEnd();
		glLoadIdentity();
//*/
/*		
		glBegin(GL_LINE_LOOP);
		float degToRad = DEG2RAD;
		for(int j = 1; j < 8; j++)
		for (int i = 1; i < 5; i++)
		{
			float degInRad = i * j * degToRad * 9;
			glVertex2f(cos(degInRad) * size.width / 2.f * 1.42f + position.x, 
					   sin(degInRad) * size.height / 2.f * 1.42f + position.y);
		}
		glEnd();
//*/

/*
		float angle = 0;// blob.angle;
		float lenght = (1.f - blob.position.x) / cos(angle * DEG2RAD);
		CGPoint endPoint = calculateEndPoint(blob.position, lenght, angle);
		
		glBegin(GL_LINES);
		glVertex2f(blob.position.x, blob.position.y);
		glVertex2f(endPoint.x, endPoint.y);
		glEnd();
//*/		
		
/*
		gluTessBeginPolygon(tess, NULL);
		gluTessBeginContour(tess);
		
		gluTessEndContour(tess);
		gluTessEndPolygon(tess);
//*/

	}
		
}

- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{	
//	newBounds.angle = 0.f;
//	newBounds.dimensions = CGSizeMake(0.f, 0.f);
	
	[super tuioBoundsAdded:newBounds];
}

- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds
{
//	updatedBounds.angle = 0.f;
	
	[super tuioBoundsUpdated:updatedBounds];
}

@end
