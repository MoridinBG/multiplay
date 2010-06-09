//
//  Superfluid.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 4/21/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import "Superfluid.h"
#import "TouchMap.h"

#import <pthread.h>

@implementation Superfluid

- (id) init
{
	if(self = [super init])
	{
		fluid = nil;
		fluid = [[Fluid2D alloc] initWithSize:MESH_SIZE
									 timeStep:TIME_STEP
								 andViscosity:VISCOSITY];
//*		
		NSInvocationOperation* evolution = [[NSInvocationOperation alloc] initWithTarget:fluid
																			 selector:@selector(evolve) 
																			   object:nil];
		
		operationQueue = [[NSOperationQueue alloc] init];
		[operationQueue addOperation:evolution];
//*/		
//		[self addBlurFilter];
	}
	return self;
}

- (void) finalize
{
	[operationQueue cancelAllOperations];
	fluid.operationCanceled = true;
	
	[super finalize];
}

- (CGPoint) calibratePoint:(CGPoint) point 
{	
	float oldX = point.x;
	float oldY = point.y;
	
	float maxX = 1.f;
	float minX = 0.f;
	
	float maxY = 0.f;
	float minY = 1.f;

	float oldMaxX = _aspect;
	float oldMinX = 0.f;
	
	float oldMaxY = 1.f;
	float oldMinY = 0.f;

	
	//NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
	float newX = (((oldX - oldMinX) * (maxX - minX)) / (oldMaxX - oldMinX)) + minX;
	float newY = (((oldY - oldMinY) * (maxY - minY)) / (oldMaxY - oldMinY)) + minY;
	
	return CGPointMake(newX, newY);
}

- (void) tuioBoundsUpdated: (TuioBounds*) updatedBounds
{	
	CGPoint position = [self calibratePoint:updatedBounds.position];
	CGPoint lastPosition = [self calibratePoint:updatedBounds.lastPosition];
	
	CGPoint movementVelocity;
	CGPoint lastMovementVelocity = updatedBounds.lastMovementVelocity;
	
 	float timeElapsed = updatedBounds.updateTime - updatedBounds.lastUpdateTime;

	//Velocity vectors
	float diffX, diffY; //a, b
	diffX = position.x - lastPosition.x;
	diffY = position.y - lastPosition.y;
	
	//Calculate velocity (unless tracker sends reliable data
	if (diffX && diffY && timeElapsed)
	{
		movementVelocity = CGPointMake(diffX / (timeElapsed / 100.f),
									   diffY / (timeElapsed / 100.f));
	} else 
	{ 
		movementVelocity = CGPointMake(0.f, 0.f);
	}
	
//	NSLog(@"%f, %f", movementVelocity.x, lastMovementVelocity.x);
	
	//Calculate acceleration
	float accelX, accelY;// ad, bd
	accelX = movementVelocity.x - lastMovementVelocity.x;
	accelY = movementVelocity.y - lastMovementVelocity.y;
	
	//Make position difference absolute
	if (position.x < lastPosition.x)
		diffX *= -1;
	if (position.y < lastPosition.y)
		diffY *= -1;
	
	//Make velocity difference absolute
	if (movementVelocity.x < lastMovementVelocity.x)
		accelX *= -1;
	if (movementVelocity.y < lastMovementVelocity.y)
		accelY *= -1;
	
	//Calculate the tangent between the last point and the new point and interpolate over it for smoother effect
	float posTangent = sqrt((diffX * diffX) + (diffY * diffY));
	
	float k = 0;
	CGPoint intermedPos;
	CGPoint intermedVel;
	
	if (posTangent && (updatedBounds.lastPosition.x || updatedBounds.lastPosition.y))
	{
		while ( k <= 100.0f )
		{
			// some vector math to calculate the intermediary positions and velocities
			intermedPos.x = lastPosition.x - ((k/100.0f) * (lastPosition.x - position.x));
			intermedPos.y = lastPosition.y - ((k/100.0f) * (lastPosition.y - position.y));
			intermedVel.x = lastMovementVelocity.x - ((k/100.0f) * (lastMovementVelocity.x - movementVelocity.x));
			intermedVel.y = lastMovementVelocity.y - ((k/100.0f) * (lastMovementVelocity.y - movementVelocity.y));
			
			// don't draw the last position twice
			if (CGPointEqualToPoint(position, intermedPos))
				break;
			
			intermedPos.y = 1.f - intermedPos.y;
			intermedVel.y *= -1.f;
			[fluid dragAt:intermedPos withVelocity:intermedVel withColor:[objectColors objectForKey:[updatedBounds getKey]]];
			
			// increment by a fraction of the tangent length
			//  - this avoids drawing too often on short moves
			k +=  1 / (posTangent * 2);
		}
	}
	
	updatedBounds.lastMovementVelocity = movementVelocity;
}

- (void) addBlurFilter
{
	CIFilter *blur = [CIFilter filterWithName:@"CIBoxBlur"];
	[blur setDefaults];
	blur.name = @"blur";
	[self setFilters:[NSArray arrayWithObjects:blur, nil]];
}

- (void) drawGL
{
//	[fluid evolve];
	int i, j, idx;
	
	fftw_real  wn = (fftw_real)(self.frame.size.width / self.frame.size.height) / (fftw_real)(MESH_SIZE - 1);   /* Grid element width */
	fftw_real  hn = (fftw_real)1.f / (fftw_real)(MESH_SIZE - 1);  /* Grid element height */
	
	CGPoint pixelPos;
	
	const fftw_real* redDensity = fluid.redDensity;
	const fftw_real* greenDensity = fluid.greenDensity;
	const fftw_real* blueDensity = fluid.blueDensity;
	
	if (IS_WIREFRAME)
	{
		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	} else {
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}
	for (j = 0; j < (MESH_SIZE - 1); j++)
	{
		glBegin(GL_TRIANGLE_STRIP);
		
		i = 0;
		pixelPos.x = (fftw_real) i * wn;
		pixelPos.y = (fftw_real) j * hn;
		idx = (j * MESH_SIZE) + i;
		glColor3f(redDensity[idx], greenDensity[idx], blueDensity[idx]);
		glVertex2f(pixelPos.x, pixelPos.y);
		
		for (i = 0; i < MESH_SIZE - 1; i++) 
		{
			pixelPos.x = (fftw_real) i * wn;
			pixelPos.y = (fftw_real) (j + 1) * hn;
			idx = ((j + 1) * MESH_SIZE) + i;
			glColor3f(redDensity[idx], greenDensity[idx], blueDensity[idx]);
			glVertex2f(pixelPos.x, pixelPos.y);
			
			pixelPos.x = (fftw_real) (i + 1) * wn;
			pixelPos.y = (fftw_real) j * hn;
			idx = (j * MESH_SIZE) + (i + 1);
			glColor3f(redDensity[idx], greenDensity[idx], blueDensity[idx]);
			glVertex2f(pixelPos.x, pixelPos.y);
		}
		
		pixelPos.x = (fftw_real) (MESH_SIZE - 1) * wn;
		pixelPos.y = (fftw_real) (j + 1) * hn;
		idx = ((j + 1) * MESH_SIZE) + (MESH_SIZE - 1);
		glColor3f(redDensity[idx], greenDensity[idx], blueDensity[idx]);
		glVertex2f(pixelPos.x, pixelPos.y);

		glEnd();
	}
}



@end
