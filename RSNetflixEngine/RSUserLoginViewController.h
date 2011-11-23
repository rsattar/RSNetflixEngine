//
//  RSUserLoginViewController.h
//  RSNetflixEngine
//
//  Created by Rizwan on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSUserLoginViewController;

@protocol RSUserLoginViewControllerDelegate <NSObject>

- (void)userLoginViewControllerSucceeded:(RSUserLoginViewController *)viewController withResponse:(NSDictionary *)loginResponse;
- (void)userLoginViewControllerCancelled:(RSUserLoginViewController *)viewController;

@end

@interface RSUserLoginViewController : UIViewController <UIWebViewDelegate> {

    id<RSUserLoginViewControllerDelegate> delegate;
    
}

@property(assign) id<RSUserLoginViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *loginUrl;
@property (copy, nonatomic) NSString *callBackUrl;

- (IBAction)cancelButtonTapped:(id)sender;

@end
