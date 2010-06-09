//
//  RGBTrailes.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RGBTrailes.h"


@implementation RGBTrailes

- (id) init
{
	if(self = [super init])
	{
		[self addBlurFilter];
	}
	return self;
}

- (void) addBlurFilter
{
	CIFilter *blur = [CIFilter filterWithName:@"CIDiscBlur"];
	[blur setDefaults];
	blur.name = @"blur";
	[blur setValue:[NSNumber numberWithFloat:4.f] forKey:@"inputRadius"];
	[self setFilters:[NSArray arrayWithObjects:blur, nil]];
}

- (void) drawGL
{
	NSArray *keys = [objects allKeys];
	NSNumber *key;
	InteractiveObject *blob;
	RGBA *color;
	for(key in keys)
	{
		blob = [objects objectForKey:key];
		color = [objectColors objectForKey:key];

		if(color.a == 1.f)
			if((arc4random() % 100) > 50)
				color.a = 0.f;
			else
				color.a = 3.f;
//*
		RGBA *colors[6];
		colors[0] = [[RGBA alloc] initWithR:1.f
									  withG:0.f
									  withB:0.f
									  withA:0.65f];
		
		colors[1] = [[RGBA alloc] initWithR:0.f
									  withG:1.f
									  withB:0.f
									  withA:0.65f];
		
		colors[2] = [[RGBA alloc] initWithR:0.f
									  withG:0.f
									  withB:1.f
									  withA:0.65f];
		
		colors[3] = [[RGBA alloc] initWithR:1.f
									  withG:1.f
									  withB:0.f
									  withA:0.65f];
		
		colors[4] = [[RGBA alloc] initWithR:1.f
									  withG:0.f
									  withB:1.f
									  withA:0.65f];
		
		colors[5] = [[RGBA alloc] initWithR:0.f
									  withG:1.f
									  withB:1.f
									  withA:0.65f];
		
		int index = [blob.pointsHistory count] - CONTOURS_BACK * 3;
		int colorIndex = color.a;
		
		while((index > 0) && (index <= ([blob.pointsHistory count] - CONTOURS_BACK)))
		{
			NSArray *contour = [blob.pointsHistory objectAtIndex:index];
			int count = [contour count];
			GLdouble vertices[count][3];
			
			glColor4f(colors[colorIndex].r,
					  colors[colorIndex].g,
					  colors[colorIndex].b,
					  1.f);//colors[colorIndex].a);
			
			gluTessBeginPolygon(tess, NULL);
			gluTessBeginContour(tess);
			
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
			
			colorIndex++;
			index += CONTOURS_BACK;
		}
//*/
	}
}

@end
