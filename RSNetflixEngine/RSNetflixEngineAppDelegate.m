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
    NSData *apiContextData = (NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:@"netflixAPIContext"];
    if(apiContextData != nil) {
        netflixAPIContext = [[NSKeyedUnarchiver unarchiveObjectWithData:apiContextData] retain];
    } else {
        netflixAPIContext = [[RSNetflixAPIContext alloc] initWithConsumerKey:RS_NETFLIX_ENGINE_API_KEY sharedSecret:RS_NETFLIX_ENGINE_SHARED_SECRET applicationName:RS_NETFLIX_ENGINE_APPLICATION_NAME];
    }
    
    NSString *loginCallback = @"foo://bar";//@"http://doesnotexistbutuniqueenoughtocatch.com";
    netflixAPIContext.userLoginCallbackUrl = loginCallback;//[self urlEncodedStringFromString:loginCallback];
    
    mainViewController.netflixAPIContext = netflixAPIContext;
    
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
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
    NSData *apiContextData = [NSKeyedArchiver archivedDataWithRootObject:netflixAPIContext];
    [[NSUserDefaults standardUserDefaults] setObject:apiContextData forKey:@"netflixAPIContext"];
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
    [mainViewController release];
    [super dealloc];
}

@end
