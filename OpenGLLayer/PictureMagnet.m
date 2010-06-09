//
//  PictureMagnet.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 5/18/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

// BEHOLD!!! HORRIBLE HACKS AHAID!

#import "PictureMagnet.h"

@implementation PictureMagnet

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	NSLog(@"Here");
//	CALayer *presentation = [theAnimation.delegate presentationLayer];
//	movieLayer.position = presentation.position;
}

- (void) setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	NSError *error;
	movies = [[NSMutableArray alloc] init];
	followers = [[NSMutableDictionary alloc] init];
	
	for(int i = 0; i < MOVIES; i++)
	{
		NSString *path;
		CGSize size;
		if((arc4random() % 10) > 5)
		{
			path = @"/Users/ivandilchovski/Movies/TultiMouch/Fish.mov";
			size = CGSizeMake(147, 191);
		} else 
		{
			path = @"/Users/ivandilchovski/Movies/TultiMouch/Butterfly.mov";
			size = CGSizeMake(286, 203);
		}

		
		QTMovie *movie = [QTMovie movieWithFile:path error:&error];
		[movie setAttribute:[NSNumber numberWithBool:TRUE] forKey:@"QTMovieLoopsAttribute"];
		[movie play];
		
		CGPoint initialPosition = [self getRandomPointWithinDimension];
		initialPosition = CGPointMake(initialPosition.x * bounds.size.height, 
									  initialPosition.y * bounds.size.height);
		
		QTMovieLayer *movieLayer = [QTMovieLayer layerWithMovie:movie];
		movieLayer.frame = CGRectMake(initialPosition.x, initialPosition.y, size.width * 0.6f, size.height * 0.6f);
		
		[movies addObject:movieLayer];
		[self addSublayer:movieLayer];
		
		[NSTimer scheduledTimerWithTimeInterval:0.05f
										 target:self
									   selector:@selector(layerMoved:) 
									   userInfo:movieLayer
										repeats:NO];
	}
}

- (void) layerMoved:(NSTimer*)timer
{
	QTMovieLayer *movieLayer;
	
	if([timer.userInfo isKindOfClass:[NSMutableArray class]])
	{
		NSMutableArray *pair = timer.userInfo;
		NSNumber *key = [pair objectAtIndex:0];
		movieLayer = [pair objectAtIndex:1];
		
		[[followers objectForKey:key] removeObject:movieLayer];
		
	} 
	else if([timer.userInfo isKindOfClass:[QTMovieLayer class]])
	{
		movieLayer = timer.userInfo;
	}
	
	if((arc4random() % 100) > 33)
	{
		CGPoint target = [self getRandomPointWithinDimension];
		target = CGPointMake(target.x * self.bounds.size.height,
							 target.y * self.bounds.size.height);
		
		float duration = [GlobalFunctions lengthBetweenPoint:movieLayer.position andPoint:target];
		duration /= self.bounds.size.height;
		
		float angle = [GlobalFunctions findAngleBetweenPoint:movieLayer.position andPoint:target];
		CATransform3D transform = CATransform3DMakeRotation ((angle - 90.f) * DEG2RAD, 0, 0, 1);
		
		[CATransaction setValue:[NSNumber numberWithFloat:duration * 3.5f]
						 forKey:kCATransactionAnimationDuration];
		movieLayer.position = target;
		
		[CATransaction setValue:[NSNumber numberWithFloat:duration]
						 forKey:kCATransactionAnimationDuration];
		movieLayer.transform = transform;
		
		[NSTimer scheduledTimerWithTimeInterval:duration * 3.5f * 0.7f
										 target:self
									   selector:@selector(layerMoved:) 
									   userInfo:movieLayer
										repeats:NO];
	} else if([[objects allKeys] count])
	{
		int index = arc4random() % [[objects allKeys] count];
		NSNumber *uid = [[objects allKeys] objectAtIndex:index];
		NSMutableArray *fellows;
		NSMutableArray *pair = [[NSMutableArray alloc] initWithCapacity:2];
		
		[pair addObject:uid];
		[pair addObject:movieLayer];
		
		fellows = [followers objectForKey:uid];
		if(!fellows)
			fellows = [[NSMutableArray alloc] init];
		
		[fellows addObject:movieLayer];
		[followers setObject:fellows forKey:uid];
		
		[NSTimer scheduledTimerWithTimeInterval:10 + (arc4random() % 20)
										 target:self
									   selector:@selector(layerMoved:) 
									   userInfo:pair
										repeats:NO];
	} else
		[self layerMoved:timer]; //FIXME: WRONG conditioning. Fix for arc4random < 33 && no objects.

}

- (void) drawGL
{
	NSArray *keys = [objects allKeys];
	NSNumber *key;

	keys = [followers allKeys];
	for(key in keys) //FIXME: Terrible hacks ahead. Reimplement the case when the object asociated with a movie has disappeared 
	{
		InteractiveObject *object = [objects objectForKey:key];
		NSMutableArray *fellows = [followers objectForKey:key];
		
		for(QTMovieLayer *movieLayer in fellows)
		{
			if(!object)
			{
				[NSTimer scheduledTimerWithTimeInterval:0.01f
												 target:self
											   selector:@selector(layerMoved:) 
											   userInfo:movieLayer
												repeats:NO];
			}
			CALayer *presentation = [movieLayer presentationLayer];
			CGPoint layerToGLPoint = CGPointMake(presentation.position.x / self.bounds.size.height,
												 presentation.position.y / self.bounds.size.height);
			float length = [GlobalFunctions lengthBetweenPoint:object.position andPoint:layerToGLPoint];
			length -= movieLayer.bounds.size.height / self.bounds.size.height / 2.f;
			length -= object.size.width / 2.f;
			
			float angle = [GlobalFunctions findAngleBetweenPoint:layerToGLPoint andPoint:object.position];
			CATransform3D transform = CATransform3DMakeRotation ((angle - 90.f) * DEG2RAD, 0, 0, 1);
			
			CGPoint targetPoint = [GlobalFunctions findEndPointForStart:layerToGLPoint
															 withLength:length
																atAngle:angle];
			targetPoint.x *= self.bounds.size.height;
			targetPoint.y *= self.bounds.size.height;
			
			if(length < 0.2f)
				length = 0.2f;
			[CATransaction setValue:[NSNumber numberWithFloat:length * 0.8f]
							 forKey:kCATransactionAnimationDuration];
			movieLayer.position = targetPoint;
			
			[CATransaction setValue:[NSNumber numberWithFloat:0.1f]
							 forKey:kCATransactionAnimationDuration];
			movieLayer.transform = transform;
		}
		if(!object)
			[fellows removeAllObjects];
	}
}

@end
