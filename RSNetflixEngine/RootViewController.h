//
//  RootViewController.h
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 Rizwan Sattar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSNetflixEngine.h"

@interface RootViewController : UITableViewController {
    RSNetflixEngine *netflixEngine;
}

@property(retain, nonatomic) RSNetflixEngine *netflixEngine;


@end
