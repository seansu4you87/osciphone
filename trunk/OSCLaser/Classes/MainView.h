//
//  MainView.h
//  OSCLaser
//
//  Created by Ben Cunningham on 1/31/10.
//  Copyright Stanford University 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCPort, MainViewController;

@interface MainView : UIView {
	MainViewController * parent;
}

@property(nonatomic, assign) MainViewController * parent;

@end
