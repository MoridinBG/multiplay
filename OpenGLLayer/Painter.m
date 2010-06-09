//
//  Painter.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/4/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "Painter.h"

@implementation Painter

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
	CIFilter *blur = [CIFilter filterWithName:@"CIBoxBlur"];
	[blur setDefaults];
	[blur setValue:[NSNumber numberWithFloat:15.f] forKey:@"inputRadius"];
	blur.name = @"blur";
	[self setFilters:[NSArray arrayWithObjects:blur, nil]];
}

- (void)drawInCGLContext:(CGLContextObj)glContext 
             pixelFormat:(CGLPixelFormatObj)pixelFormat 
            forLayerTime:(CFTimeInterval)interval 
             displayTime:(const CVTimeStamp *)timeStamp 
{
	GLint previousFBO, previousReadFBO, previousDrawFBO;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, &previousFBO);
	glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING_EXT, &previousReadFBO);
	glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING_EXT, &previousDrawFBO);
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboId);
	
	[self drawGL];
	glColor3f(1.f, 1.f, 1.f);

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, previousFBO);  
	glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, previousReadFBO);
	glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, previousDrawFBO);
	
	glClearColor(BACKGROUND, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);

	glBindTexture(GL_TEXTURE_2D, textureId);
	
	float aspect = self.frame.size.width / self.frame.size.height;
	
	glBegin(GL_QUADS);
	glTexCoord2f(0.f, 0.f);
	glVertex2f(0.f, 0.f);
	glTexCoord2f(1.0f, 0.f);
	glVertex2f(aspect, 0.f);
	glTexCoord2f(1.0f, 1.0f);
	glVertex2f(aspect, 1.f);
	glTexCoord2f(0.0f, 1.0f);
	glVertex2f(0.f, 1.f);
	glEnd();
	
	glBindTexture(GL_TEXTURE_2D, 0);
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
		
		glColor3f(color.r,
				  color.g,
				  color.b);
		
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

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat 
{
	CGLContextObj contextObj = [super copyCGLContextForPixelFormat:pixelFormat];
	
	float width = self.frame.size.width;
	float height = self.frame.size.height;
	
	glGenTextures(1, &textureId);
	glBindTexture(GL_TEXTURE_2D, textureId);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0,
				 GL_RGBA, GL_UNSIGNED_BYTE, 0);

	glEnable(GL_TEXTURE_2D);
	
	// create a framebuffer object
	glGenFramebuffersEXT(1, &fboId);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboId);
	
	// attach the texture to FBO color attachment point
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, 
							  GL_COLOR_ATTACHMENT0_EXT,
							  GL_TEXTURE_2D, 
							  textureId, 
							  0);
	
	glClearColor(BACKGROUND, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
	if(status != GL_FRAMEBUFFER_COMPLETE_EXT)
	{
		NSLog(@"Hereee");
	}
	return contextObj;
}
@end
