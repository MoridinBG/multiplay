//
//  Fluid2D.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/21/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "Fluid2D.h"


@implementation Fluid2D
@synthesize u = _u;
@synthesize v = _v;

@synthesize redDensity = _r;
@synthesize greenDensity = _g;
@synthesize blueDensity = _b;

@synthesize operationCanceled = _operationCanceled;

- (id) initWithSize:(int)size timeStep:(float)timeStep andViscosity:(float) viscosity
{
	if(self = [super init])
	{
		_size = size;
		_timeStep = timeStep;
		_viscosity = viscosity;
		
		_time = 0.0;
		
		_u = (fftw_real*) malloc(sizeof(fftw_real) * (size * 2 * ((size / 2) + 1)));
		_v = (fftw_real*) malloc(sizeof(fftw_real) * (size * 2 * ((size / 2) + 1)));
		_u0 = (fftw_real*) malloc(sizeof(fftw_real) * (size * 2 * ((size / 2) + 1)));
		_v0 = (fftw_real*) malloc(sizeof(fftw_real) * (size * 2 * ((size / 2) + 1)));
		
		_r = (fftw_real*) malloc(sizeof(fftw_real) * (size * size));
		_r0 = (fftw_real*) malloc(sizeof(fftw_real) * (size * size));
		_g = (fftw_real*) malloc(sizeof(fftw_real) * (size * size));
		_g0 = (fftw_real*) malloc(sizeof(fftw_real) * (size * size));
		_b = (fftw_real*) malloc(sizeof(fftw_real) * (size * size));
		_b0 = (fftw_real*) malloc(sizeof(fftw_real) * (size * size));
		
		_u_u0 = (fftw_real*) malloc(sizeof(fftw_real) * (size * size));
		_u_v0 = (fftw_real*) malloc(sizeof(fftw_real) * (size * size));

		_plan_rc = rfftw2d_create_plan(size, size, FFTW_REAL_TO_COMPLEX, FFTW_IN_PLACE);
		_plan_cr = rfftw2d_create_plan(size, size, FFTW_COMPLEX_TO_REAL, FFTW_IN_PLACE);

		for( int i = 0; i < size * size; i++ )
		{
			_u[i] = _v[i] = _u0[i] = _v0[i] = _u_u0[i] = _u_v0[i] = 0.0f;
			_r[i] = _r0[i] = _g[i] = _g0[i] = _b[i] = _b0[i] = 0.0f;
		}
	}
	
	return self;
}

- (void) finalize
{
	free(_u);
	free(_v);
	free(_u0);
	free(_v0);
	free(_r);
	free(_g);
	free(_b);
	free(_r0);
	free(_g0);
	free(_b0);
	free(_u_u0);
	free(_u_v0);
	
	[super finalize];
}

- (void) setOperationCanceled:(_Bool)ca
{
	_operationCanceled = ca;
}

- (void) evolve
{
	while (!_operationCanceled) 
	{
		[self setForces];
		[self stableSolveWithViscosity:_viscosity andTimeStep:_timeStep];
		[self diffuseMatterWithTimeStep:_timeStep];
		[self zeroBoundary];
		
		_time += (fftw_real) _timeStep;
		usleep(20000);
	}
}

- (void) stableSolveWithViscosity:(float)viscosity andTimeStep:(float)timeStep
{
	fftw_real x, y, x0, y0, f, r, U[2], V[2], s, t;
	int i, j, i0, j0, i1, j1;
	
	for (i=0; i < _size * _size; i++)
	{
		_u[i] += timeStep * _u0[i]; 
		_u0[i] = _u[i];
		
		_v[i] += timeStep * _v0[i]; 
		_v0[i] = _v[i];
	}    
	
	for(x = 0.5f / _size,i = 0 ; i < _size ; i++, x += 1.0f / _size)
	{
		for(y = 0.5f / _size,j = 0; j < _size; j++, y += 1.0f / _size)
		{
			x0 = _size * (x - timeStep * _u0[i + _size * j]) - 0.5f; 
			y0 = _size * (y - timeStep * _v0[i + _size * j]) - 0.5f;
			i0 = floor(x0);
			s = x0 - i0;
			i0 = (_size + (i0 % _size)) % _size;
			i1 = (i0 + 1) % _size;
			j0 = floor(y0);
			t = y0 - j0;
			j0 = (_size + (j0 % _size)) % _size;
			j1 = (j0 + 1) % _size;
			_u[i + _size * j] = (1 - s) * ((1 - t) * _u0[i0 + _size * j0] + t * _u0[i0 + _size * j1]) +
			s * ((1 - t) * _u0[i1 + _size * j0] + t * _u0[i1 + _size * j1]);
			_v[i + _size * j] = (1 - s) * ((1 - t) * _v0[i0 + _size * j0] + t * _v0[i0 + _size * j1]) +
			s * ((1 - t) * _v0[i1 + _size * j0] + t * _v0[i1 + _size *j1]);
		}    
	} 
	
	for(i = 0; i < _size; i++)
		for(j = 0; j < _size; j++)
		{ 
			_u0[i + (_size + 2) * j] = _u[i + _size * j]; 
			_v0[i + (_size + 2) * j] = _v[i + _size * j];
		}
	
	FFT(1, _u0);
	FFT(1, _v0);
	
	for(i = 0; i <= _size; i += 2)
	{
		x = 0.5f * i;
		for(j = 0; j < _size; j++)
		{
			y = j <= _size / 2 ? (fftw_real)j : (fftw_real)j - _size;
			r = (x * x) + (y * y);
			
			if(r == 0.0f) 
				continue;
			
			f = (fftw_real)exp(-r * timeStep * viscosity);
			U[0] = _u0[i +(_size + 2) * j]; 
			V[0] = _v0[i +(_size + 2) * j];
			U[1] = _u0[i + 1 + (_size + 2) * j];
			V[1] = _v0[i + 1 + (_size + 2) * j];
			
			_u0[i + (_size + 2) * j] = f * ( (1-x*x/r)*U[0]     -x*y/r *V[0] );
			_u0[i+1+(_size + 2) * j] = f * ( (1-x*x/r)*U[1]     -x*y/r *V[1] );
			_v0[i+  (_size + 2) * j] = f * (   -y*x/r *U[0] + (1-y*y/r)*V[0] );
			_v0[i+1+(_size + 2) * j] = f * (   -y*x/r *U[1] + (1-y*y/r)*V[1] );
		}    
	}
	
	FFT(-1,_u0); 
	FFT(-1,_v0);
	
	f = 1.0 / (_size * _size);
	for(i = 0; i < _size; i++)
		for(j = 0; j < _size; j++)
		{
			_u[i + _size * j] = f * _u0[i + (_size + 2) * j]; 
			_v[i + _size * j] = f * _v0[i + (_size + 2) * j]; 
		}
}

- (void) diffuseMatterWithTimeStep:(float)timeStep
{
	fftw_real x, y, x0, y0, s, t;
	int i, j, i0, j0, i1, j1;
	
	for(x = 0.5f / _size, i = 0 ;i < _size; i++, x += 1.0f / _size) 
	{
		for(y = 0.5f / _size, j = 0; j < _size; j++, y += 1.0f / _size) 
		{
			x0 = _size * (x - timeStep * _u[i + _size * j]) - 0.5f; 
			y0 = _size * (y - timeStep * _v[i + _size * j]) - 0.5f;
			i0 = floor(x0);
			s = x0 - i0;
			i0 = (_size + (i0 % _size)) % _size;
			i1 = (i0 + 1) % _size;
			j0 = floor(y0);
			t = y0 - j0;
			j0 = (_size + (j0 % _size)) % _size;
			j1 = (j0 + 1) % _size;
			
			_r[ i+ _size * j] = ((1 - s) * ((1 - t) * _r0[i0 + _size * j0] + t * _r0[i0 + _size * j1]) +                        
			s * ((1 - t) * _r0[i1 + _size * j0] + t * _r0[i1 + _size * j1])) * FADE_FACTOR;
			//usleep( 1 );
			_g[i + _size * j] = ((1 - s) * ((1 - t) * _g0[i0 + _size * j0] + t * _g0[i0 + _size * j1]) +                        
			s * ((1 - t) * _g0[i1 + _size * j0] + t * _g0[i1 + _size * j1])) * FADE_FACTOR;
			_b[i + _size * j] = ((1 - s) * ((1 - t) * _b0[i0 + _size * j0] + t * _b0[i0 + _size * j1]) +                        
			s * ((1 - t) * _b0[i1 + _size * j0] + t * _b0[i1 + _size * j1])) * FADE_FACTOR;
			
		}    
	} 
}

- (void) zeroBoundary
{
	for( int i=0; i<_size; i++ )
	{
		// bottom edge
		_u[0 * _size + i] = 0.0;
		_v[0 * _size + i] = 0.0;
		_u0[0 * _size + i] = 0.0;
		_v0[0 * _size + i] = 0.0;
		
		// top edge
		_u[(_size - 1) * _size + i] = 0.0;
		_v[(_size - 1) * _size + i] = 0.0;
		_u0[(_size - 1) * _size + i] = 0.0;
		_v0[(_size - 1) * _size + i] = 0.0;
		
		// left edge
		_u[i * _size + 0] = 0.0;
		_v[i * _size + 0] = 0.0;
		_u0[i * _size + 0] = 0.0;
		_v0[i * _size + 0] = 0.0;
		
		// right edge
		_u[i * _size + _size - 1] = 0.0;
		_v[i * _size + _size - 1] = 0.0;
		_u0[i * _size + _size - 1] = 0.0;
		_v0[i * _size + _size - 1] = 0.0;
	}
}

- (void) dragAt:(CGPoint)position withVelocity:(CGPoint)velocity withColor:(RGBA*)color
{
	int     xi;
	int     yi;
	float  len;
	int     X, Y;
	
	// Compute the array index that corresponds to the cursor location
	xi = (int)floor((float)(_size + 1) * position.x);
	yi = (int)floor((float)(_size + 1) * position.y);
	
	X = xi;
	Y = yi;
	
	if (X > (_size - 1)) {
		X = _size - 1;
	}
	if (Y > (_size - 1)) {
		Y = _size - 1;
	}
	if (X < 0) {
		X = 0;
	}
	if (Y < 0) {
		Y = 0;
	}
	
	// Add force at the cursor location
	len = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
	if (len != 0.0) 
	{ 
		velocity.x *= 0.1 / len;
		velocity.y *= 0.1 / len;
	}
	_u_u0[Y * _size + X] += velocity.x;
	_u_v0[Y * _size + X] += velocity.y;
	
	// Increase matter densities at the cursor location
	_r[Y * _size + X] = 8.0f * color.r; 
	_r0[Y * _size + X] = _r[Y * _size + X];
	_g[Y * _size + X] = 8.0f * color.g; 
	_g0[Y * _size + X] = _g[Y * _size + X];
	_b[Y * _size + X] = 8.0f * color.b; 
	_b0[Y * _size + X] = _b[Y * _size + X];
}

- (void) setForces
{
	for (int i = 0; i < _size * _size; i++) 
	{
		_r0[i] = 0.995 * _r[i]; 
		_g0[i] = 0.995 * _g[i]; 
		_b0[i] = 0.995 * _b[i]; 
		
		_u_u0[i] *= 0.85;
		_u_v0[i] *= 0.85;
		
		_u0[i] = _u_u0[i];
		_v0[i] = _u_v0[i];
	}
}

@end
