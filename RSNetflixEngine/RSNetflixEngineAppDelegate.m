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
    /*
    RSNetflixAPIRequest *request = [[RSNetflixAPIRequest alloc] initWithAPIContext:netflixAPIContext];
    request.delegate = self;
    [request callAPIMethod:RSNetflixMethodSearchPeople arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"max_results",@"frances mc",@"term", nil] isSigned:YES];
    */
    
    /*
    netflix = [[RSNetflixEngine alloc] initWithAPIContext:netflixAPIContext];
    netflix.delegate = self;
    //[netflixEngine searchForTitlesMatchingTerm:@"Star"];
    oAuthRequestId = [[netflix requestOAuthToken] retain];
    */
    
    // Testing blocks out with API Requests
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
}

@end
