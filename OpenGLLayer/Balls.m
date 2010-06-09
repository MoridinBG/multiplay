//
//  Balls.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/15/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "Balls.h"

@implementation Balls

- (id) init
{
	if(self = [super init])
	{
		sludges = [[NSMutableArray alloc] init];
		touches = [[NSMutableDictionary alloc] init];
		
		[self addBlurFilter];
	}
	return self;
}

- (void) addBlurFilter
{
	CIFilter *blur = [CIFilter filterWithName:@"CIBoxBlur"];
	[blur setDefaults];
	[blur setValue:[NSNumber numberWithFloat:10.f] forKey:@"inputRadius"];
	blur.name = @"blur";
	[self setFilters:[NSArray arrayWithObjects:blur, nil]];
}

- (void) setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	physics = [[b2Physics alloc] init];
	[physics createGroundWithDimensions:self.frame.size];

	[self addBlob];
}

- (void) addBlob
{
	float radius = 0.15f;
	CGPoint position;
	do 
	{
		position = [self getRandomPointWithinDimension];
	} while ((position.x < radius) || (position.x > (_aspect - radius)) || (position.y < radius) || (position.y > (1.f - radius)));
	
	InteractiveObject *blob = [[InteractiveObject alloc] initAtPosition:position
																atAngle:0.f
															   withSize:CGSizeMake(radius, radius)];
	blob.points = [physics createBlobAt:position
							 withRadius:radius];
	blob.color = [RGBA randomColorWithMinimumValue:30];
	[sludges addObject:blob];
}

- (void) drawGL
{
	[physics step];
	NSArray *keys = [touches allKeys];
	NSNumber *uid;
	for(uid in keys)
	{
		
		InteractiveObject *body = [touches objectForKey:uid];
		glColor3f(body.color.r, body.color.g, body.color.b);
//*
		glPushMatrix();
		glTranslated(body.position.x, body.position.y, 0.f);
		glBegin(GL_LINE_LOOP);
		glVertex2f(-body.size.width / 2.f, -body.size.height / 2.f);
		glVertex2f(body.size.width / 2.f, -body.size.height / 2.f);
		glVertex2f(body.size.width / 2.f, body.size.height / 2.f);
		glVertex2f(-body.size.width / 2.f, body.size.height / 2.f);
		glEnd();
		glPopMatrix();
//*/
//		[body renderBasicShape];
	}
	
	for(InteractiveObject *blob in sludges)
	{
		glColor4f(blob.color.r, blob.color.g, blob.color.b, blob.color.a);
/*
//		glBegin(GL_LINE_LOOP);
		for(InteractiveObject *point in blob.points)
		{
			point.color = blob.color;
//			glVertex2f(point.position.x, point.position.y);
			[point renderBasicShape];
		}
//		glEnd();
//*/
		
//*
		gluTessBeginPolygon(tess, NULL);
		gluTessBeginContour(tess);
		
		int count = [blob.points count];
		GLdouble vertices[count][3];
		int i = 0;
		for(InteractiveObject *point in blob.points)
		{
			vertices[i][0] = point.position.x;
			vertices[i][1] = point.position.y;
			vertices[i][2] = 0.f;
			gluTessVertex(tess, vertices[i], vertices[i]);
			i++;
		}
		gluTessEndContour(tess);
		gluTessEndPolygon(tess);
//*/
	}
	return;	
	glColor3f(1.f, 1.f, 1.f);
	glBegin(GL_LINE_LOOP);
	glVertex2f(0.05f, 0.05f);
	glVertex2f(_aspect - 0.05f, 0.05f);
	
	glVertex2f(_aspect - 0.05f, 0.05f);
	glVertex2f(_aspect - 0.05f, 1.f - 0.05f);
	
	glVertex2f(_aspect - 0.05f, 1 - 0.05f);
	glVertex2f(0.05f, 1- 0.05f);
	glEnd();
}

- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{
	[super tuioBoundsAdded:newBounds];
	InteractiveObject *obj = [physics createPolygonBodyAtPosition:newBounds.position
														withSize:newBounds.dimensions
														rotatedAt:0.f];
	obj.color = [RGBA randomColorWithMinimumValue:30];
	obj.uid = [newBounds getKey];
	obj.points = newBounds.contour;
	[physics attachMouseJointToBody:obj.physicsData 
							 withId:[newBounds getKey]];
	[touches setObject:obj forKey:[newBounds getKey]];
	
}

- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds
{
	[super tuioBoundsUpdated:updatedBounds];
	
	[physics updateMouseJointWithId:[updatedBounds getKey]
						 toPosition:updatedBounds.position];
	InteractiveObject *touch = [touches objectForKey:[updatedBounds getKey]];
	touch.points = updatedBounds.contour;
}

- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds
{
	[super tuioBoundsRemoved:deadBounds];
	
	[physics detachMouseJointWithId:[deadBounds getKey]];
	InteractiveObject *obj = [touches objectForKey:[deadBounds getKey]];
	[obj destroyPhysicsData];
	[touches removeObjectForKey:[deadBounds getKey]];
}
@end
