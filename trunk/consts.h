/*
 *  consts.h
 *  Finger
 *
 *  Created by Ivan Dilchovski on 7/16/09.
 *  Copyright 2009 The Pixel Factory. All rights reserved.
 *
 */
#define DEBUG_GENERAL_STATE TRUE

#define DEBUG_TOUCH_STATE FALSE
#define DEBUG_TOUCH_MOVE_STATE FALSE
#define DEBUG_LISTENER_STATE FALSE
#define DEBUG_LISTENER_MOVE_STATE FALSE
#define DEBUG_RENDER_STATE FALSE

#define COLOR_BITS (NSOpenGLPixelFormatAttribute)24
#define DEPTH_BITS (NSOpenGLPixelFormatAttribute)16
#define FULLSCREEN NO


#define PI 3.14159f
#define SECTORS_RIPPLE 30
#define SECTORS_SPARKLE 14
#define SECTORS_TOUCH 30
#define MAX_TOUCHES 100

static const int MOUSE_ID = -1;
typedef enum touchtype {TouchDown, TouchMove, TouchRelease} TouchType;
typedef enum debugstate {DEBUG_TOUCH, DEBUG_TOUCH_MOVE, DEBUG_LISTENER, DEBUG_LISTENER_MOVE, DEBUG_GENERAL, DEBUG_RENDER} DebugState;