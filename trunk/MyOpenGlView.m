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
		
		projectionSize.size.width = 750;
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
//		GLint swapInterval = 1; 
//		CGLSetParameter (CGLGetCurrentContext(), kCGLCPSwapInterval, &swapInterval);
		
		if(!success)
		{
			NSLog(@"Error on initWithFrame:");
			return nil;
		}
		
		CGLError err = 0;
		CGLContextObj ctx = CGLGetCurrentContext();
        
		// Enable the multi-threading
		err =  CGLEnable( ctx, kCGLCEMPEngine);
        
		if (err != kCGLNoError )
		{
			NSLog(@"Here");
		}    
		
//		provider = [[Sparkles alloc] init];
//		provider = [[Stars alloc] init];
//		provider = [[SineConnect alloc] init];
//		provider = [[LineConnect alloc] init];
// 		provider = [[TextCircle alloc] init];
//		provider = [[Ripples alloc] init];
//		provider = [[InteractiveImages alloc] initWithPicturesInDirectory:@"/Users/ivandilchovski/Logos/"];
//		provider = [[TouchTrail alloc] init];
		provider = [[TouchSwap alloc] init];
		
		[provider setDimensions:[self dimensions]];
		
		color.r = ((float)(arc4random() % 255)) / 255;
		color.g = ((float)(arc4random() % 255)) / 255;
		color.b = ((float)(arc4random() % 255)) / 255;
		color.a = 1.0f;
		
		newColor = color;
		
		(void)[NSTimer scheduledTimerWithTimeInterval:(1.f / FRAMES)
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
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable (GL_POLYGON_SMOOTH);
	glEnable (GL_LINE_SMOOTH);
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	
	glLineWidth(3);
	
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
	CGSize dimensions = [self dimensions];
	float ratio = dimensions.width / dimensions.height;
	
	
	if([provider isKindOfClass:[TextCircle class]])
	{
		gluPerspective(90, ratio, 1, 1000);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		
//		gluLookAt(1560.0, 320.0, 320, 1560.0, 320.0, 0.0, 0.0, 1.0, 0.0);
		gluLookAt(520, 320, 320, 520, 320, 0, 0, 1, 0);
	}
	else
	{
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
		
		glOrtho(0, ratio, 0, 1.0, 0, 1.0);
		
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
	}
}

- (void)drawRect:(NSRect)rect
{
//	[self randomizeColor];
//	glClearColor(color.r, color.g, color.b, color.a);
	glClearColor(0, 0, 0, 0);
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

- (CGSize) dimensions
{
	CGSize dimensions;
	if(!fullscreen)
	{
		dimensions.width = (unsigned int)[self frame].size.width;
		dimensions.height = (unsigned int)[self frame].size.height;
	}
	else
	{
		if((CGDisplayPixelsWide(kCGDirectMainDisplay) == 1680) || (CGDisplayPixelsWide(kCGDirectMainDisplay) == 1280))
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
	if(fullscreen)
	{
		fullscreen = NO;
		[_fullscreenContext clearDrawable];
		[_windowContext makeCurrentContext];
		CGReleaseAllDisplays();
		
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
	}
}

- (void) randomizeColor
{
	if(color.r != newColor.r)
	{
		if((color.r > newColor.r) && (colorStep.r > 0))
		{
			newColor.r = (((float)(arc4random() % 255)) / 750);
			colorStep.r = (newColor.r - color.r) / BACKGROUND_COLOR_STEP;
		}
		if((color.r < newColor.r) && (colorStep.r < 0))
		{
			newColor.r = (((float)(arc4random() % 255)) / 750);
			colorStep.r = (newColor.r - color.r) / BACKGROUND_COLOR_STEP;
		}
		color.r += colorStep.r;
	}
	else
	{
		newColor.r = (((float)(arc4random() % 255)) / 750);
		colorStep.r = (newColor.r - color.r) / BACKGROUND_COLOR_STEP;
	}
	
	if(color.g != newColor.g)
	{
		if((color.g > newColor.g) && (colorStep.g > 0))
		{
			newColor.g = (((float)(arc4random() % 255)) / 750);
			colorStep.g = (newColor.g - color.g) / BACKGROUND_COLOR_STEP;
		}
		if((color.g < newColor.g) && (colorStep.g < 0))
		{
			newColor.g = (((float)(arc4random() % 255)) / 750);
			colorStep.g = (newColor.g - color.g) / BACKGROUND_COLOR_STEP;
		}
		color.g += colorStep.g;
	}
	else
	{
		newColor.g = (((float)(arc4random() % 255)) / 750);
		colorStep.g = (newColor.g - color.g) / BACKGROUND_COLOR_STEP;
	}
	
	if(color.b != newColor.b)
	{
		if((color.b > newColor.b) && (colorStep.b > 0))
		{
			newColor.b = (((float)(arc4random() % 255)) / 750);
			colorStep.b = (newColor.b - color.b) / BACKGROUND_COLOR_STEP;
		}
		if((color.b < newColor.b) && (colorStep.b < 0))
		{
			newColor.b = (((float)(arc4random() % 255)) / 750);
			colorStep.b = (newColor.b - color.b) / BACKGROUND_COLOR_STEP;
		}	
		color.b += colorStep.b;
	}
	else
	{
		newColor.b = (((float)(arc4random() % 255)) / 750);
		colorStep.b = (newColor.b - color.b) / BACKGROUND_COLOR_STEP;
	}
}
@end
