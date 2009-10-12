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
#define DEBUG_PHYSICS_STATE FALSE

#define COLOR_BITS (NSOpenGLPixelFormatAttribute)24
#define DEPTH_BITS (NSOpenGLPixelFormatAttribute)16
#define FULLSCREEN FALSE
#define SIMULATOR TRUE

#define PI 3.14159f
#define DEG2RAD PI / 180.0f
#define SECTORS_STARS 30
#define SECTORS_SPARKLE 14
#define SECTORS_TOUCH 30
#define MAX_TOUCHES 100

#define SENSOR_RANGE 0.6f
#define SINECONNECT_NUM_VERTICES 72

#define FONT_SCALE 0.05

#define BACKGROUND_COLOR_STEP 400

static const int MOUSE_ID = -1;
typedef enum touchtype {TouchDown, TouchMove, TouchRelease} TouchType;
typedef enum debugstate {DEBUG_TOUCH, DEBUG_TOUCH_MOVE, DEBUG_LISTENER, DEBUG_LISTENER_MOVE, DEBUG_GENERAL, DEBUG_RENDER, DEBUG_PHYSICS} DebugState;

typedef struct 
{
	float r;
	float g;
	float b;
	float a;
} RGBA;