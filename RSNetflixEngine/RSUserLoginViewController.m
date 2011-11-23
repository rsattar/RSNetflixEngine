//
//  RSUserLoginViewController.m
//  RSNetflixEngine
//
//  Created by Rizwan on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSUserLoginViewController.h"

@implementation RSUserLoginViewController
@synthesize delegate;
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

// Inspired (lifted) by https://github.com/mattgemmell/MGTwitterEngine
- (BOOL) delegateSupportsSelector:(SEL)selector
{
	return ((delegate != nil) && [delegate respondsToSelector:selector]);
}

- (IBAction)cancelButtonTapped:(id)sender {
    
    if([self delegateSupportsSelector:@selector(userLoginViewControllerCancelled:)]) {
        [delegate userLoginViewControllerCancelled:self];
    }
}

- (NSDictionary *)getQueryDictionaryFromURL:(NSURL *)url {
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
    if(url) {
        NSString *existingParamString = url.query;
        if([existingParamString length] > 0) {
            // Separate into & bits first
            NSArray *pairs = [existingParamString componentsSeparatedByString:@"&"];
            for (NSInteger i = 0; i < pairs.count; i++) {
                NSArray *split = [[pairs objectAtIndex:i] componentsSeparatedByString:@"="];
                // These objects are already url encoded, so just set them into the dictionary
                [paramsDictionary setObject:[split objectAtIndex:1] forKey:[split objectAtIndex:0]];
            }
        }
    }
    return paramsDictionary;
}

#pragma - WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = request.URL.absoluteString;
    
    if([urlString hasPrefix:callBackUrl]) {
        // we got called back!
        
        // https://api-user.netflix.com/oauth/foo%3A%2F%2Fbar?oauth_token=sq3mnwaqx6t3bawdb85f23yq&oauth_verifier=

        // foo://bar?oauth_token=t8vc52qy8q8j4mc448g3stj5&oauth_verifier=
        NSDictionary *loginSuccessReponse = [self getQueryDictionaryFromURL:request.URL];
        if([self delegateSupportsSelector:@selector(userLoginViewControllerSucceeded:withResponse:)]) {
            [delegate userLoginViewControllerSucceeded:self withResponse:loginSuccessReponse];
        }
        
        return NO;
    } else {
        return YES;
    }
    
}
@end
