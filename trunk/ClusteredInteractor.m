//
//  ClusteredInteractor.m
//  Finger
//
//  Created by Ivan Dilchovski on 10/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import "ClusteredInteractor.h"


@implementation ClusteredInteractor
@synthesize cluster;
@synthesize visibleItems;
@synthesize clusterAlpha;

- (id) initWithItems:(NSMutableArray*) items
{
	if (self = [super init])
	{
		cluster = items;
		visibleItems = [cluster count];
		clusterAlpha = 1.f;
	}
	
	return self;
}

- (void) setItemsPosition:(CGPoint) pos
{
	position = pos;
	int count = [cluster count];
	for(int i = 0; i < count; i++)
	{
		InteractiveObject *item = [cluster objectAtIndex:i];
		item.position = pos;
	}
}

- (int) getItemsCount
{
	return [cluster count];
}

-(void) setClusterColor:(RGBA) newColor
{
	for(InteractiveObject *item in cluster)
		item.color = newColor;
}

@end
