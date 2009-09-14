//
//  Sparkle.h
//  Finger
//
//  Created by Ivan Dilchovski on 9/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Sparkle : NSObject 
{
	CGPoint position;
	CGPoint direction;
	float alpha;
}
@property CGPoint position;
@property CGPoint direction;
@property float alpha;

- (id) initAtPosition:(CGPoint) aPosition withDirection:(CGPoint) aDirection withAlpha:(float) aAlpha;

@end
