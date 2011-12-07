//
//  RawResponseViewController.h
//  RSNetflixEngine
//
//  Created by Rizwan on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RawResponseViewController : UIViewController {
    NSString *textToShow;
}


@property (retain, nonatomic) IBOutlet UITextView *responseTextView;

- (void)displayResponse:(NSDictionary *)response;
- (void)displayError:(NSError *)error withAdditionalText:(NSString *)text;

@end
