//
//  AlphaChangeContainer.h
//  OpenGLLayer
//
//  Created by Ivan Dilchovski on 6/7/10.
//  Copyright 2010 Bulplex LTD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AlphaChangeContainer : NSObject 
{
	float _alpha;
	float _changeStep;
	
	int _changeSign;
	int _framesTillChange;
}

@property float alpha;
@property float changeStep;
@property int changeSign;
@property int framesTillChange;

- (id) initRandom;

@end
