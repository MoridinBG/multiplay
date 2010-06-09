//
//  MyView.m
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 03/26/10.
//  Copyright 2010 Ivan Dilchovski. All rights reserved.
//
#import "CAHandView.h"

@implementation CAHandView

- (void)awakeFromNib 
{
	_tuioClient = [[TuioClient alloc] initWithPortNumber:3333 andDelegateDimensions:self.bounds.size];
	allEffects = [[NSMutableArray alloc] init];
	currentEffects = [[NSMutableArray alloc] init];
	
	[allEffects addObject:[Painter class]];
	[allEffects addObject:[BoundariesBurn class]];
	[allEffects addObject:[RGBTrailes class]];
	[allEffects addObject:[Superfluid class]];
	[allEffects addObject:[Balls class]];
	[allEffects addObject:[PictureMagnet class]];
	[allEffects addObject:[Connector class]];
	[allEffects addObject:[Steps class]];
	
	[currentEffects addObjectsFromArray:allEffects];
	
	self.layer = [CALayer layer];
	
	bgLayer = [GLBackgroundLayer layer];
	bgLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	[self.layer addSublayer:bgLayer];
	
//*	
	rotationTimer = [NSTimer scheduledTimerWithTimeInterval:ROTATE_INTERVAL
															   target:self
															 selector:@selector(rotateLayers:) 
															 userInfo:nil
															  repeats:YES];
	[rotationTimer fire];
//*/

/*
	BlobMask *maskLayer = [BlobMask layer];
	maskLayer.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
	[self.layer addSublayer:maskLayer];
	[_tuioClient.boundsDelegates addObject:maskLayer];
//*/
	
	self.wantsLayer = YES;
}

- (void) rotateLayers:(NSTimer *)theTimer
{
	if(currentContentLayer)
	{
		[currentContentLayer removeFromSuperlayer];
		[_tuioClient.boundsDelegates removeObject:currentContentLayer];
		[_tuioClient reload];
	}
	
//	int index = arc4random() % [currentEffects count];
//	currentContentLayer = [[currentEffects objectAtIndex:index] layer];
//	[currentEffects removeObjectAtIndex:index];

	currentContentLayer = [Connector layer];
	
	if(![currentEffects count])
		[currentEffects addObjectsFromArray:allEffects];
	
	[_tuioClient.boundsDelegates addObject:currentContentLayer];
	currentContentLayer.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
	[self.layer addSublayer:currentContentLayer];
}

@end
