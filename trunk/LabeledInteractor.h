//
//  LabeledInteractor.h
//  Finger
//
//  Created by Mood on 9/19/09.
//  Copyright 2009 The Pixel Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InteractiveObject.h"

@interface LabeledInteractor : InteractiveObject
{
	NSString *label;
	int charsToTrimAtEnd;
	int charsToTrimAtStart;
}
@property (copy) NSString *label;
@property int charsToTrimAtEnd;
@property int charsToTrimAtStart;
@end
