//
//  RSNetflixEngineAppDelegate.h
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 Rizwan Sattar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSNetflixEngine.h"
#import "RSUserLoginViewController.h"

@interface RSNetflixEngineAppDelegate : NSObject <UIApplicationDelegate, RSNetflixEngineDelegate, RSUserLoginViewControllerDelegate> {

    RSNetflixEngine *netflix;
    RSNetflixAPIContext *netflixAPIContext;
    
    RSUserLoginViewController *loginViewController;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
