//
//  BorderlessWindow.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BorderlessWindow.h"


@implementation BorderlessWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	
//	contentRect.origin.x = 70;
//	contentRect.origin.y = 80;
	
    self = [super initWithContentRect:contentRect 
							styleMask:NSBorderlessWindowMask 
							  backing:NSBackingStoreBuffered 
								defer:NO];
    if (self != nil) 
	{
//		[self setAlphaValue:1.0];
//		[self setOpaque:NO];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow 
{
    return YES;
}

@end
