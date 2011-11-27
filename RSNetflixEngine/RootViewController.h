//
//  RootViewController.h
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 Rizwan Sattar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSNetflixEngine.h"
#import "RSUserLoginViewController.h"

@interface RootViewController : UITableViewController <RSNetflixEngineDelegate, RSUserLoginViewControllerDelegate> {
    RSNetflixEngine *netflix;
    RSNetflixAPIContext *netflixAPIContext;
    
    RSUserLoginViewController *loginViewController;
}

@property(retain, nonatomic) RSNetflixAPIContext *netflixAPIContext;

@end
