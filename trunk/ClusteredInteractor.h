//
//  ClusteredInteractor.h
//  Finger
//
//  Created by Ivan Dilchovski on 10/4/09.
//  Copyright 2009 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InteractiveObject.h"

@interface ClusteredInteractor : InteractiveObject 
{
	NSArray *cluster;
	int visibleItems;
	
	float clusterAlpha;
}
@property (readonly) NSArray *cluster;
@property int visibleItems;
@property float clusterAlpha;


- (id) initWithItems:(NSArray*) items;

- (void) setItemsPosition:(CGPoint) pos;

- (int) getItemsCount;

-(void) setClusterColor:(RGBA) newColor;
@end
