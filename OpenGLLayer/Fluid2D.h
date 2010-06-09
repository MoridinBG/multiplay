//
//  Fluid2D.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/21/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//


/*
 Objective-C port of the C++ port of Gustav Taxen's (gustavt@nada.kth.se) C implementation
 of Jos Stam's fast 2D fluid solver, itself built on five hundred
 years of unpatented work in the study of turbulence.
 
 Portions of this code by Gustav Taxen,
 http://www.nada.kth.se/~gustavt/fluids/
 
 Portions of the code by Jos Stam, from the paper "A Simple Fluid 
 Solver Based on the FFT", available at
 http://www.dgp.utoronto.ca/people/stam/reality/Research/pub.html
 */

#import <Cocoa/Cocoa.h>

#import "Fftw.h"
#import "Rfftw.h"
#import "RGBA.h"

#define FADE_FACTOR 0.96f

#define floor(x) ((x)>=0.0?((int)(x)):(-((int)(1-(x)))))
#define FFT(s,u)\
if(s==1) rfftwnd_one_real_to_complex(_plan_rc,(fftw_real *)u,(fftw_complex*)u);\
else rfftwnd_one_complex_to_real(_plan_cr,(fftw_complex *)u,(fftw_real *)u)

@interface Fluid2D : NSObject 
{
	fftw_real *_u, *_v, *_u0, *_v0;  // velocity field
	fftw_real *_r, *_r0;  // density field for colour r
	fftw_real *_g, *_g0;  // density field for colour g
	fftw_real *_b, *_b0;  // density field for colour b
	fftw_real *_u_u0, *_u_v0;  // user-induced forces
	
	int _size;
	rfftwnd_plan _plan_rc, _plan_cr;
	fftw_real _time;
	float _timeStep, _viscosity;
	
	bool _operationCanceled;
}
@property(readonly) fftw_real *u;
@property(readonly) fftw_real *v;

@property(readonly) fftw_real *redDensity;
@property(readonly) fftw_real *greenDensity;
@property(readonly) fftw_real *blueDensity;

@property bool operationCanceled;

- (id) initWithSize:(int)size timeStep:(float)timeStep andViscosity:(float) viscosity;

- (void) evolve;
- (void) stableSolveWithViscosity:(float)viscosity andTimeStep:(float)timeStep;

- (void) dragAt:(CGPoint)position withVelocity:(CGPoint)velocity withColor:(RGBA*)color;

- (void) diffuseMatterWithTimeStep:(float)timeStep;
- (void) zeroBoundary;
- (void) setForces;

@end
