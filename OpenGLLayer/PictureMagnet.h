//
//  PictureMagnet.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/18/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#define MOVIES 6

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <QTKit/QTKit.h> //QTMovieLayer

#import "GLContentLayer.h"
#import "GlobalFunctions.h"

@interface PictureMagnet : GLContentLayer
{
	NSMutableArray *movies;
	NSMutableDictionary *followers;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;
- (void) setBounds:(CGRect)bounds;

- (void) layerMoved:(NSTimer*)timer;

- (void) drawGL;

@end
