//
//  MyOpenGlView.m
//  Finger
//
//  Created by Ivan Dilchovski on 7/15/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import "MyOpenGlView.h"

@implementation MyOpenGLView

- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect])
	{
		bool success = true;
		projectionSize.origin.x = 177;
		projectionSize.origin.y  = 0;
		
		projectionSize.size.width = 510;
		projectionSize.size.height = 525;
		
		short MAXDISPLAYS = 4;
		CGDisplayCount displayCount;
		CGDirectDisplayID displays[MAXDISPLAYS];
		CGGetOnlineDisplayList(MAXDISPLAYS, displays, &displayCount);
		
		NSOpenGLPixelFormatAttribute attribs[] = {
			NSOpenGLPFAFullScreen,
			NSOpenGLPFANoRecovery,
			NSOpenGLPFAMultisample,
			NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)1,
			NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)4,
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADoubleBuffer,
//			(NSOpenGLPixelFormatAttribute)CGDisplayIDToOpenGLDisplayMask(displays[0]),
//			(NSOpenGLPixelFormatAttribute)CGDisplayIDToOpenGLDisplayMask(displays[1]),
			NSOpenGLPFAColorSize, COLOR_BITS,
			NSOpenGLPFADepthSize, DEPTH_BITS,
			NSOpenGLPFAScreenMask,
			(NSOpenGLPixelFormatAttribute)CGDisplayIDToOpenGLDisplayMask(CGCaptureAllDisplays()),
			(NSOpenGLPixelFormatAttribute)0
		};
		NSOpenGLPixelFormat *_windowFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];	
		if(_windowFormat == nil)
			NSLog(@"Cannot create windowed pixel format!");
		
		attribs[0] = NSOpenGLPFAFullScreen;
		NSOpenGLPixelFormat *_fullscreenFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];	
		if(_fullscreenFormat == nil)
			NSLog(@"Cannot create fullscreen pixel format!");
		
		_windowContext = [[NSOpenGLContext alloc] initWithFormat:[_windowFormat autorelease] 
													shareContext:_fullscreenContext ];	// Not sure this is okay or not but it
		if(_windowContext == nil)
			NSLog(@"Cannot create windowed OpenGL context!");
		
		_fullscreenContext = [[NSOpenGLContext alloc] initWithFormat:[_fullscreenFormat autorelease] shareContext:_windowContext];
		if(_fullscreenContext == nil)
			NSLog(@"Cannot create fullscreen OpenGL context!");	
		
		fullscreen = !FULLSCREEN;	// Reverse this
		[self fullscreen:self];		// Because this will toggle

		//Enable VSync to prevent tearing
		GLint swapInterval = 1; 
		CGLSetParameter (CGLGetCurrentContext(), kCGLCPSwapInterval, &swapInterval);
		
		if(!success)
		{
			NSLog(@"Error on initWithFrame:");
			return nil;
		}
		
//		provider = [[Sparkles alloc] init];
//		provider = [[Ripples alloc] init];
		provider = [[SineConnect alloc] init];
		
		[provider setDimensions:[self dimensions]];
		
		(void)[NSTimer scheduledTimerWithTimeInterval:0.024
											   target:self 
											 selector:@selector(display) 
											 userInfo:nil 
											  repeats:YES];
	}
	return self;
}


- (void)lockFocus
{
	NSOpenGLContext* context = [self openGLContext];	
	[super lockFocus];
	if([context view] != self)
		if(!fullscreen) 
			[context setView:self];
	
	[context makeCurrentContext];
	glEnable (GL_BLEND);
	glEnable (GL_POLYGON_SMOOTH);
	glEnable (GL_LINE_SMOOTH);
	glDisable(GL_DEPTH_TEST);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glLineWidth(4);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	NSSize dimensions = [self dimensions];
	float ratio = dimensions.width / dimensions.height;

	
	if(CGDisplayPixelsWide(kCGDirectMainDisplay) == 800)
	{
		glViewport(projectionSize.origin.x,
				   projectionSize.origin.y,
				   projectionSize.size.width,
				   projectionSize.size.height);
	} else
	{
		glViewport(0, 0, dimensions.width, dimensions.height);
	}
	
	glOrtho(-ratio, ratio, -1.0, 1.0, -1.0, 1.0);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

}

- (void)drawRect:(NSRect)rect
{
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);

	[provider render];
	
	[[self openGLContext] flushBuffer];
}

- (NSOpenGLContext *)openGLContext
{
	if(fullscreen)
		return _fullscreenContext;
	else
		return _windowContext;
}

- (NSSize) dimensions
{
	NSSize dimensions;
	if(!fullscreen)
	{
		dimensions.width = (unsigned int)[self frame].size.width;
		dimensions.height = (unsigned int)[self frame].size.height;
	}
	else
	{
		if(CGDisplayPixelsWide(kCGDirectMainDisplay) == 1680)
		{
			dimensions.width = CGDisplayPixelsWide(kCGDirectMainDisplay);
			dimensions.height = CGDisplayPixelsHigh(kCGDirectMainDisplay);
		} else
			dimensions = projectionSize.size;
	}

	return dimensions;
}

- (void) fullscreen:(id)sender
{
	float width, height;
	if(fullscreen)
	{
		fullscreen = NO;
		[_fullscreenContext clearDrawable];
		[_windowContext makeCurrentContext];
		CGReleaseAllDisplays();
		
		width = (unsigned int)[self frame].size.width;
		height = (unsigned int)[self frame].size.height;
	}
	else
	{
		short MAXDISPLAYS = 4;
		CGDisplayCount displayCount;
		CGDirectDisplayID displays[MAXDISPLAYS];
		CGGetOnlineDisplayList(MAXDISPLAYS, displays, &displayCount);
		
		fullscreen = YES;
		
//		CGDisplayCapture(displays[1]);
		CGCaptureAllDisplays();
		
		[_fullscreenContext setFullScreen];
		[_fullscreenContext makeCurrentContext];
		
		width = CGDisplayPixelsWide(kCGDirectMainDisplay);
		height = CGDisplayPixelsHigh(kCGDirectMainDisplay);
	}
}
@end
