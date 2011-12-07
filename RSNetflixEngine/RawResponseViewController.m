//
//  RawResponseViewController.m
//  RSNetflixEngine
//
//  Created by Rizwan on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RawResponseViewController.h"

@implementation RawResponseViewController
@synthesize responseTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(textToShow) {
        responseTextView.text = textToShow;
        [textToShow release];
    }
}

- (void)viewDidUnload
{
    [self setResponseTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [responseTextView release];
    [textToShow release];
    [super dealloc];
}

#pragma mark - Displaying information
- (void)displayResponse:(NSDictionary *)response
{
    NSString *responseText = [NSString stringWithFormat:@"%@",response];
    if(responseTextView) {
        responseTextView.text = responseText;
    } else {
        textToShow = [responseText retain];
    }
}

- (void)displayError:(NSError *)error withAdditionalText:(NSString *)text
{
    
    NSString *errorText = [NSString stringWithFormat:@"%@\n%@",error,text];
    if(responseTextView) {
        responseTextView.text = errorText;
    } else {
        textToShow = [errorText retain];
    }
}
@end
