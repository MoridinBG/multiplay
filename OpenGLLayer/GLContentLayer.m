//
//  OpenGLLayer.m
//  OpenGLLayer
//
//  Created by Bill Dudney on 11/30/07.
//  Copyright 2007 Gala Factory. All rights reserved.
//

#import "GLContentLayer.h"

@implementation GLContentLayer

@synthesize animate = _animate;
@synthesize tuioBounds = _tuioBounds;

void tessEndCB()
{
    glEnd();
}

void tessBeginCB(GLenum which)
{
    glBegin(which);
}

void tessErrorCB(GLenum errorCode)
{
    const GLubyte *errorStr;
	
    errorStr = gluErrorString(errorCode);
	printf("Error: %s\n", errorStr);
}

void tessVertexCB(const GLvoid *data)
{
    const GLdouble *ptr = (const GLdouble*)data;
    glVertex3dv(ptr);
}

void tessCombineCB(GLdouble coords[3], 
				   GLdouble *vertex_data[4],
				   GLfloat weight[4], GLdouble **dataOut )
{
	GLdouble *vertex;
	
	vertex = (GLdouble *) malloc(3 * sizeof(GLdouble));
	vertex[0] = coords[0];
	vertex[1] = coords[1];
	vertex[2] = coords[2];

	*dataOut = vertex;
}

- (id)init 
{
	if(self = [super init])
	{
		self.asynchronous = YES;
		objects = [[NSMutableDictionary alloc] init];
		objectColors = [[NSMutableDictionary alloc] init];
		
		clearBitfield =	GL_COLOR_BUFFER_BIT;
		
		tess = gluNewTess();
		gluTessCallback(tess, GLU_TESS_BEGIN, (void (CALLBACK *)())tessBeginCB);
		gluTessCallback(tess, GLU_TESS_END, (void (CALLBACK *)())tessEndCB);
		gluTessCallback(tess, GLU_TESS_ERROR, (void (CALLBACK *)())tessErrorCB);
		gluTessCallback(tess, GLU_TESS_VERTEX, (void (CALLBACK *)())tessVertexCB);
		gluTessCallback(tess, GLU_TESS_COMBINE, (void (CALLBACK *)())tessCombineCB);
	}
	return self;
}

- (void) setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	_aspect = bounds.size.width / bounds.size.height;
}

- (void)drawInCGLContext:(CGLContextObj)glContext 
             pixelFormat:(CGLPixelFormatObj)pixelFormat 
            forLayerTime:(CFTimeInterval)interval 
             displayTime:(const CVTimeStamp *)timeStamp 
{	
	glClearColor(0.f, 0.f, 0.f, 0.0f);
	glClear(clearBitfield);
	
	[self drawGL];
}

- (void)releaseCGLPixelFormat:(CGLPixelFormatObj)pixelFormat 
{
	CGLDestroyPixelFormat(pixelFormat);
}

- (CGLPixelFormatObj)copyCGLPixelFormatForDisplayMask:(uint32_t)mask 
{
	CGLPixelFormatAttribute attribs[] =
	{
		kCGLPFAAccelerated,
		kCGLPFADoubleBuffer,
		kCGLPFAColorSize, 24,
		kCGLPFADepthSize, 16,
		0
	};
	
	CGLPixelFormatObj pixelFormatObj = NULL;
	GLint numPixelFormats = 0;
	
	CGLChoosePixelFormat(attribs, &pixelFormatObj, &numPixelFormats);
	return pixelFormatObj;
}

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pixelFormat 
{
	CGLContextObj contextObj = NULL;
	CGLCreateContext(pixelFormat, NULL, &contextObj);
	if(contextObj == NULL)
		NSLog(@"Error: Could not create context!");
	
	// Enable OpenGL multi-threading
	CGLError err = 0;
//	err =  CGLEnable( contextObj, kCGLCEMPEngine);
	if (err != kCGLNoError )
	{
		NSLog(@"Error switching to Multi Threaded OpenGL!");
	}  
	
	CGLSetCurrentContext(contextObj);
	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable (GL_LINE_SMOOTH);
	
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
	glOrtho(0, self.bounds.size.width / self.bounds.size.height, 0, 1.0, -1.0, 1.0);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	return contextObj;
}

- (void) drawGL
{
	if(DEBUG_RENDER_STATE)
		[Logger logMessage:@"Rendering frame" ofType:DEBUG_RENDER_STATE];
}

- (CGPoint) getRandomPointWithinDimension
{
	CGSize dimensions;
	dimensions.width = self.bounds.size.width / self.bounds.size.height;
	dimensions.height = 1.f;
	
	int x = (dimensions.width * 1000) - 100;
	int y = (dimensions.height * 1000) - 100;
	
	return CGPointMake((arc4random() % x) / 1000.f, (arc4random() % y) / 1000.f);
}

- (void) tuioBoundsAdded: (TuioBounds*) newBounds
{
	InteractiveObject *object = [InteractiveObject interactiveFrom:newBounds];
	object.color = [RGBA randomColorWithMinimumValue:MIN_RANDOM_COLOR];
	[objects setObject:object
				forKey:[newBounds getKey]];

	[objectColors setObject:object.color
					 forKey:[newBounds getKey]];
}

- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds
{
	InteractiveObject *object = [objects objectForKey:[updatedBounds getKey]];
	if(object)
	{
		[object updateWithTuioBounds:updatedBounds];
	}
}

- (void) tuioBoundsRemoved: (TuioBounds*) deadBounds
{
	[objects removeObjectForKey:[deadBounds getKey]];
	[objectColors removeObjectForKey:[deadBounds getKey]];
}

- (void) tuioFrameFinished
{
}

@end
