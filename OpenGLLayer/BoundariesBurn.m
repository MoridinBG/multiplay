//
//  BoundariesBurn.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BoundariesBurn.h"

@implementation BoundariesBurn

- (id) init
{
	if(self = [super init])
	{
		[self addBurningFilter];
	}
	return self;
}

- (void) addBurningFilter
{
	CIFilter *bloom = [CIFilter filterWithName:@"CIBloom"];
	[bloom setDefaults];
	bloom.name = @"bloom";
//	[self setFilters:[NSArray arrayWithObjects:bloom, nil]];
	
	CIFilter *blur = [CIFilter filterWithName:@"CIDiscBlur"];
	[blur setDefaults];
	[blur setValue:[NSNumber numberWithFloat:3.f] forKey:@"inputRadius"];
	blur.name = @"blur";
	[self setFilters:[NSArray arrayWithObjects:bloom, blur, nil]];
	
	[self setValue:[NSNumber numberWithFloat:5.0f]
		forKeyPath:[NSString stringWithFormat:@"filters.bloom.%@", kCIInputIntensityKey]];
	[self setValue:[NSNumber numberWithFloat:20.0f]
		forKeyPath:[NSString stringWithFormat:@"filters.bloom.%@", kCIInputRadiusKey]];
	
	
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

		glColor3f(1.f, 0.5f, 0.f);		
//		glColor3f(color.r, color.g, color.b);
		
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
	}
}
@end
