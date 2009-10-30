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
#define DEBUG_ERROR_STATE TRUE

#define RENDER_SENSOR_RANGE FALSE
#define RENDER_BOX2D_DEBUG_DRAW TRUE

#define COLOR_BITS (NSOpenGLPixelFormatAttribute)24
#define DEPTH_BITS (NSOpenGLPixelFormatAttribute)16

#define FULLSCREEN FALSE
#define SIMULATOR TRUE

#define TOUCH_PHYSICS_BODY_SIZE 0.05f
#define PHYSICS_DRAG_ELASTICITY 10000.f

#define PI 3.14159f
#define DEG2RAD PI / 180.0f
#define RAD2DEG 180.f / PI
#define SECTORS_STARS 30
#define SECTORS_SPARKLE 14
#define SECTORS_TOUCH 30

#define MAX_TOUCHES 100

#define SENSOR_RANGE 0.6f
#define SINECONNECT_NUM_VERTICES 72

#define FONT_SCALE 0.05f
#define BACKGROUND_COLOR_STEP 400

#define BASE_PICTURE_SIZE 0.15f
#define PICTURES_TO_SHOW 20

static const int MOUSE_ID = -1;
typedef enum touchtype {TouchDown, TouchMove, TouchRelease} TouchType;
typedef enum debugstate {DEBUG_TOUCH, DEBUG_TOUCH_MOVE, DEBUG_LISTENER, DEBUG_LISTENER_MOVE, DEBUG_GENERAL, DEBUG_RENDER, DEBUG_PHYSICS, DEBUG_ERROR} DebugState;

typedef struct 
{
	float r;
	float g;
	float b;
	float a;
} RGBA;