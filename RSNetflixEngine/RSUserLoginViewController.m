//
//  RSUserLoginViewController.m
//  RSNetflixEngine
//
//  Created by Rizwan on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSUserLoginViewController.h"

@implementation RSUserLoginViewController
@synthesize webView;
@synthesize loginUrl;
@synthesize callBackUrl;

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
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:loginUrl]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [webView release];
    [super dealloc];
}
- (IBAction)cancelButtonTapped:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma - WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = request.URL.absoluteString;
    
    if([urlString hasPrefix:callBackUrl]) {
        // we got called back!
        
        // https://api-user.netflix.com/oauth/foo%3A%2F%2Fbar?oauth_token=sq3mnwaqx6t3bawdb85f23yq&oauth_verifier=

        
        
        
        
        return NO;
    } else {
        return YES;
    }
    
}
@end
