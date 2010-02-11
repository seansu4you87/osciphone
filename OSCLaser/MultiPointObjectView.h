//
//  MultiPointObjectView.h
//  OSCLaser
//
//  Created by Ben Cunningham on 2/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiPointObject;

@interface MultiPointObjectView : UIView {
	MultiPointObject * parentObject;
}

@property(nonatomic, assign) MultiPointObject * parentObject;

@end
