/*
 *  consts.h
 *  OpenGLLayer
 *
 *  Created by Ivan Dilchovski on 4/12/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#pragma mark Debug Flags
#define DEBUG_TOUCH_STATE FALSE
#define DEBUG_TOUCH_MOVE_STATE FALSE
#define DEBUG_LISTENER_STATE FALSE
#define DEBUG_LISTENER_MOVE_STATE FALSE
#define DEBUG_RENDER_STATE FALSE
#define DEBUG_PHYSICS_STATE FALSE
#define DEBUG_ERROR_STATE TRUE

#define DEBUG_GENERAL_STATE TRUE

typedef enum debugstate {DEBUG_TOUCH, DEBUG_TOUCH_MOVE, DEBUG_LISTENER, DEBUG_LISTENER_MOVE, DEBUG_GENERAL, DEBUG_RENDER, DEBUG_PHYSICS, DEBUG_ERROR} DebugState;
#pragma mark -

#pragma mark Math Constants
#define PI 3.14159265f
#define DEG2RAD PI / 180.0f
#define RAD2DEG 180.f / PI
#pragma mark -

#define MIN_RANDOM_COLOR 40
#define BACKGROUND 0.3f, 0.3f, 0.3f
//#define BACKGROUND 0.f, 0.f, 0.f

#define PHYSICS_DRAG_ELASTICITY 100.f