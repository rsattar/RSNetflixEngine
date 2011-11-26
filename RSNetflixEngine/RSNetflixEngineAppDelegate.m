//
//  RSNetflixEngineAppDelegate.m
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 Rizwan Sattar. All rights reserved.
//

#import "RSNetflixEngineAppDelegate.h"
#import "APIKeys.h"

@implementation RSNetflixEngineAppDelegate


@synthesize window=_window;

@synthesize navigationController=_navigationController;



- (NSString *)urlEncodedStringFromString:(NSString *)starting
{
    // From http://stackoverflow.com/questions/2590545/urlencoding-a-string-with-objective-c
    NSString *encoded = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                            NULL,
                                                                            (CFStringRef)starting,
                                                                            NULL,
                                                                            (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                            kCFStringEncodingUTF8 );
    return encoded;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    /*
    // Initialize RSNetflixEngine
    netflix = [[RSNetflixEngine alloc] initWithConsumerKey:@"rwbq7xmey8xhtv8tszrgk2gp" sharedSecret:@"xQ57dwQFtK" applicationName:@"Movies on Netflix"];
    // Make a test call
    //[netflix callAPIMethod:@"catalog/titles/autocomplete" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[netflix consumerKey],@"oauth_consumer_key",@"frances%20mc",@"term", nil] isSigned:NO];
    
    [netflix callAPIMethod:@"catalog/people" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"max_results",@"frances mc",@"term", nil] isSigned:YES];
    */
    
    
    netflixAPIContext = [[RSNetflixAPIContext alloc] initWithConsumerKey:RS_NETFLIX_ENGINE_API_KEY sharedSecret:RS_NETFLIX_ENGINE_SHARED_SECRET applicationName:RS_NETFLIX_ENGINE_APPLICATION_NAME];
    NSString *loginCallback = @"foo://bar";//@"http://doesnotexistbutuniqueenoughtocatch.com";
    netflixAPIContext.userLoginCallbackUrl = loginCallback;//[self urlEncodedStringFromString:loginCallback];
    /*
    RSNetflixAPIRequest *request = [[RSNetflixAPIRequest alloc] initWithAPIContext:netflixAPIContext];
    request.delegate = self;
    [request callAPIMethod:RSNetflixMethodSearchPeople arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"max_results",@"frances mc",@"term", nil] isSigned:YES];
    */
    
    
    netflix = [[RSNetflixEngine alloc] initWithAPIContext:netflixAPIContext];
    netflix.delegate = self;
    //[netflixEngine searchForTitlesMatchingTerm:@"Star"];
    //oAuthRequestId = [[netflix requestOAuthToken] retain];
    [netflix requestOAuthTokenWithSuccessBlock:^(NSString *loginUrl) {
        
        NSLog(@"OMG Received an oauth response! Login url is: %@",loginUrl);
    }
                                    errorBlock:^(NSError *error) {
                                        NSLog(@"OMG received an error for requesting oauth token via block");
                                    }];
    
    
    // Testing blocks out with API Requests
    /*
    RSNetflixAPIRequest *request = [[RSNetflixAPIRequest alloc] initWithAPIContext:netflixAPIContext];
    [request callAPIMethod:RSNetflixMethodSearchPeople 
                 arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"max_results",@"frances mc",@"term", nil] 
                  isSigned:YES
          withSuccessBlock:^(NSDictionary *response) {
              NSLog(@"Got response back as block! %@",response);
          } 
                errorBlock:^(NSError *error) {
                    NSLog(@"Got error back as block! %@", error);
                }];
     */
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [loginViewController release];
    [netflix release];
    [super dealloc];
}

#pragma mark -
#pragma mark Engine Request delegate

- (void)netflixEngine:(RSNetflixEngine *)engine requestSucceeded:(NSString *)identifier withResponse:(NSDictionary *)response
{
    NSLog(@"RSNetflixEngineDelegate didComplete for request id %@ with response \n%@", identifier, response);
}

- (void)netflixEngine:(RSNetflixEngine *)engine requestFailed:(NSString *)identifier withError:(NSError *)error
{
    NSLog(@"RSNetflixEngineDelegate didFailWithError");
}

- (void)netflixEngine:(RSNetflixEngine *)engine oAuthTokenRequestSucceededWithLoginUrlString:(NSString *)loginUrl forRequestId:(NSString *)requestId
{
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:loginUrl]];
    loginViewController = [[RSUserLoginViewController alloc] initWithNibName:@"RSUserLoginViewController" bundle:[NSBundle mainBundle]];
    loginViewController.delegate = self;
    loginViewController.loginUrl = loginUrl;
    loginViewController.callBackUrl = netflixAPIContext.userLoginCallbackUrl;
    
    [self.navigationController presentModalViewController:loginViewController animated:YES];
}

- (void)netflixEngine:(RSNetflixEngine *)engine oAuthTokenAccessSucceededForRequestId:(NSString *)requestId
{
    // Make a access-only request, like users/user_id
    [netflix retrieveUserInformationForUserId:netflix.apiContext.userId];
    
}

#pragma - RSUserLoginViewControllerDelegate

- (void)userLoginViewControllerSucceeded:(RSUserLoginViewController *)viewController withResponse:(NSDictionary *)loginResponse {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [loginViewController autorelease];
    }];
    
    //NSString *oAuthAuthorizedToken = [loginResponse objectForKey:@"oauth_token"];
    // From now on, all signed requests, will actually be made as protected requests, 
    // which has a higher quota, and can do more things
    //netflix.apiContext.oAuthAuthorizedToken = oAuthAuthorizedToken;
    
    // Now make the access_token call, so that we have the last peice of the puzzle, the authorized token and SECRET
    [netflix accessOAuthToken];
    
}
- (void)userLoginViewControllerCancelled:(RSUserLoginViewController *)viewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [loginViewController autorelease];
    }];
}

@end
