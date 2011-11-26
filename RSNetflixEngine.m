//
//  RSNetflixEngine.m
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 Rizwan Sattar. All rights reserved.
//

#import "RSNetflixEngine.h"



@interface RSNetflixEngine (PrivateMethods)

// Marking requests as active
- (void) addRequest:(RSNetflixAPIRequest *)request;
- (void) removeRequest:(RSNetflixAPIRequest *)request;

// Delegate methods
- (BOOL) isValidDelegateForSelector:(SEL)selector;

@end



@implementation RSNetflixEngine

@synthesize delegate;
@synthesize apiContext;

- (void)dealloc
{
    [apiContext release];
    
    [activeURLConnections release];
    
    [super dealloc];
}

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext
{
    if ((self = [super init])) {
        self.apiContext = inAPIContext;
        
        activeURLConnections = [[NSMutableArray array] retain];
    }
    return self;
}

#pragma mark - Delegate convenience methods
- (void)notifyDelegateOfRequestSuccess:(NSString *)requestIdentifier response:(NSDictionary *)response
{
    // Notify our engine delegate
    if([self isValidDelegateForSelector:@selector(netflixEngine:requestSucceeded:withResponse:)]) {
        [delegate netflixEngine:self requestSucceeded:requestIdentifier withResponse:response];
    }
}

- (void)notifyDelegateOfRequestFailure:(NSString *)requestIdentifier withError:(NSError *)error
{
    // Notify our engine delegate
    if([self isValidDelegateForSelector:@selector(netflixEngine:requestFailed:withError:)]) {
        [delegate netflixEngine:self requestFailed:requestIdentifier withError:error];
    }
}

#pragma mark - OAuth tokens (for getting the user's permission to access their info)

- (NSString *)requestOAuthToken
{
    return [self requestOAuthTokenWithSuccessBlock:nil errorBlock:nil];
}


- (NSString *)requestOAuthTokenWithSuccessBlock:(void (^)(NSString *))successBlock errorBlock:(void (^)(NSError *))errorBlock
{
    /* Typical response:
     2011-11-06 16:13:36.519 RSNetflixEngine[52813:10103] NetflixAPIRequestDelegate didCompleteWithResponse: 
     {
     "application_name" = "Movies on Netflix";
     "login_url" = "https://api-user.netflix.com/oauth/login?oauth_token=5edcjztdexd8em6czp2tydc4";
     "oauth_token" = 5edcjztdexd8em6czp2tydc4;
     "oauth_token_secret" = N4YDE4mPFSGF;
     }
     */
    RSNetflixAPIRequest *request = [[[RSNetflixAPIRequest alloc] initWithAPIContext:apiContext] autorelease];
    // Even though we're using blocks, we still make ourselves a delegate of this request, so that
    // we have a singular place we can account for active requests
    request.delegate = self;
    
    [self addRequest:request];
    
    return [request callAPIMethod:RSNetflixMethodRequestToken 
                        arguments:nil 
                         isSigned:YES 
                       httpMethod:RSNetflixAPIHttpMethodGet
                 withSuccessBlock:^(NSDictionary *response) {
                     NSLog(@"OAuthTokenRequest completed in RSNetflixEngine!");
                     
                     // Update our API Context with the oAuthRequestToken and oAuthRequestTokenSecret
                     apiContext.oAuthRequestToken = [response objectForKey:@"oauth_token"];
                     apiContext.oAuthRequestTokenSecret = [response objectForKey:@"oauth_token_secret"];
                     apiContext.oAuthLoginUrlFragment = [NSURL URLWithString:[response objectForKey:@"login_url"]];
                     
                     NSString *completeLoginUrlString = [apiContext constructUserLoginUrlString];
                     
                     // Now request specific
                     if([self isValidDelegateForSelector:@selector(netflixEngine:oAuthTokenRequestSucceededWithLoginUrlString:forRequestId:)]) {
                         [delegate netflixEngine:self oAuthTokenRequestSucceededWithLoginUrlString:completeLoginUrlString forRequestId:request.identifier];
                     }
                     
                     if(successBlock) {
                         successBlock(completeLoginUrlString);
                     }
                     
                 }
                       errorBlock:^(NSError *error) {
                           NSLog(@"OAuthTokenRequest failed in RSNetflixEngine!");
                           
                           if(errorBlock) {
                               errorBlock(error);
                           }
                               
                       }];
    
}

#pragma mark - Accessing OAuth Token Secret

- (NSString *)accessOAuthToken
{
    return [self accessOAuthTokenWithSuccessBlock:nil errorBlock:nil];
}

- (NSString *)accessOAuthTokenWithSuccessBlock:(void (^)(void))successBlock errorBlock:(void (^)(NSError *))errorBlock
{
    RSNetflixAPIRequest *request = [[[RSNetflixAPIRequest alloc] initWithAPIContext:apiContext] autorelease];
    // Even though we're using blocks, we still make ourselves a delegate of this request, so that
    // we have a singular place we can account for active requests
    request.delegate = self;
    
    [self addRequest:request];
    
    return [request callAPIMethod:RSNetflixMethodAccessToken 
                        arguments:nil 
                         isSigned:YES 
                       httpMethod:RSNetflixAPIHttpMethodGet
                 withSuccessBlock:^(NSDictionary *response) {
                     NSLog(@"OAuthAccesssTokenRequest completed in RSNetflixEngine with response: \n%@", response);
                     
                     if([response objectForKey:@"error"] == nil) {
                         // we got no error!
                         
                         /*
                          {
                          "oauth_token" = AUTHORIZED_TOKEN;
                          "oauth_token_secret" = AUTHORIZED_TOKEN_SECRET;
                          "user_id" = USER_ID_WHO_AUTHORIZED_US;
                          }
                         */
                         
                         // Update our API Context with the oAuthRequestToken and oAuthRequestTokenSecret
                         apiContext.oAuthAccessToken = [response objectForKey:@"oauth_token"];
                         apiContext.oAuthAccessTokenSecret = [response objectForKey:@"oauth_token_secret"];
                         apiContext.userId = [response objectForKey:@"user_id"];
                                                                  
                         // Now request specific
                         if([self isValidDelegateForSelector:@selector(netflixEngine:oAuthTokenAccessSucceededForRequestId:)]) {
                             [delegate netflixEngine:self oAuthTokenAccessSucceededForRequestId:request.identifier];
                         }
                         
                         if(successBlock) {
                             successBlock();
                         }
                         
                     } else {
                         NSLog(@"Got a error response from the server: %@",response);
                     }
                     
                 }
                       errorBlock:^(NSError *error) {
                           NSLog(@"OAuthTokenRequest failed in RSNetflixEngine!");
                           
                           if(errorBlock) {
                               errorBlock(error);
                           }
                           
                       }];
}


- (NSString *)retrieveUserInformationForUserId:(NSString *)userId
{
    return [self retrieveUserInformationForUserId:userId withSuccessBlock:nil errorBlock:nil];
}

- (NSString *)retrieveUserInformationForUserId:(NSString *)userId withSuccessBlock:(void (^)(NSDictionary *))successBlock errorBlock:(void (^)(NSError *))errorBlock
{
    RSNetflixAPIRequest *request = [[[RSNetflixAPIRequest alloc] initWithAPIContext:apiContext] autorelease];
    // Even though we're using blocks, we still make ourselves a delegate of this request, so that
    // we have a singular place we can account for active requests
    request.delegate = self;
    
    [self addRequest:request];
    
    return [request callAPIMethod:[NSString stringWithFormat:@"users/%@",userId] 
                        arguments:nil 
                         isSigned:YES 
                       httpMethod:RSNetflixAPIHttpMethodGet
                 withSuccessBlock:^(NSDictionary *response) {
                     NSLog(@"retrieveUserInformationForUserId completed in RSNetflixEngine with response: \n%@", response);
                     
                     if([response objectForKey:@"error"] == nil) {
                         // we got no error!
                         
                         // Now request specific
                         if([self isValidDelegateForSelector:@selector(netflixEngine:userInformationRetrieved:forRequestId:)]) {
                             [delegate netflixEngine:self userInformationRetrieved:response forRequestId:request.identifier];
                         }
                         
                         if(successBlock) {
                             successBlock(response);
                         }
                         
                     } else {
                         NSLog(@"Got a error response from the server: %@",response);
                     }
                     
                 }
                       errorBlock:^(NSError *error) {
                           NSLog(@"retrieveUserInformationForUserId failed in RSNetflixEngine!");
                           
                           if(errorBlock) {
                               errorBlock(error);
                           }
                           
                       }]; 
}

#pragma mark -
#pragma mark Catalog methods


- (NSString *)searchForTitlesMatchingTerm:(NSString*)term
{
    return [self searchForTitlesMatchingTerm:term withMaxResults:-1 andPageOffset:0];
}

- (NSString *)searchForTitlesMatchingTerm:(NSString*)term withMaxResults:(NSInteger)maxResults andPageOffset:(NSInteger)pageOffset
{
    if(maxResults < 0)
    {
        maxResults = 25;
    }
    if(pageOffset < 0)
    {
        pageOffset = 0;
    }
    RSNetflixAPIRequest *request = [[[RSNetflixAPIRequest alloc] initWithAPIContext:apiContext] autorelease];
    request.delegate = self;
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               [[NSNumber numberWithInteger:maxResults] stringValue],@"max_results",
                               term,@"term",
                               [[NSNumber numberWithInteger:pageOffset] stringValue],@"start_index",
                               nil];
    
    [self addRequest:request];
    return [request callAPIMethod:RSNetflixMethodSearchCatalogTitles arguments:arguments isSigned:YES httpMethod:RSNetflixAPIHttpMethodGet];
}



#pragma mark -
#pragma mark API Request delegate

- (void)netflixAPIRequest:(RSNetflixAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    [self removeRequest:inRequest];
    
    [self notifyDelegateOfRequestSuccess:inRequest.identifier response:inResponseDictionary];
}

- (void)netflixAPIRequest:(RSNetflixAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    [self removeRequest:inRequest];
    
    [self notifyDelegateOfRequestFailure:inRequest.identifier withError:inError];
}

#pragma mark Request Management
// Marking requests as active
- (void) addRequest:(RSNetflixAPIRequest *)request
{
    [activeURLConnections addObject:request];
}

- (void) removeRequest:(RSNetflixAPIRequest *)request
{
    if([activeURLConnections containsObject:request]) {
        [activeURLConnections removeObject:request];
    }
}

#pragma mark Delegate methods

// Inspired (lifted) by https://github.com/mattgemmell/MGTwitterEngine
- (BOOL) isValidDelegateForSelector:(SEL)selector
{
	return ((delegate != nil) && [delegate respondsToSelector:selector]);
}

#pragma mark -
#pragma Constant Declarations
// Declaring REST method names as constants
NSString * const RSNetflixMethodRequestToken = @"oauth/request_token";
NSString * const RSNetflixMethodAccessToken = @"oauth/access_token";

NSString * const RSNetflixMethodSearchCatalogTitles = @"catalog/titles";
NSString * const RSNetflixMethodAutocompleteCatalogTitles = @"catalog/titles/autocomplete";
NSString * const RSNetflixMethodRetrieveAllCatalogTitles = @"catalog/titles/index";

NSString * const RSNetflixMethodTitleIdTemplate = @"catalog/titles/movies/%@"; // titleId
NSString * const RSNetflixMethodSeriesIdTemplate = @"catalog/titles/series/%@"; // seriesId
NSString * const RSNetflixMethodSeasonIdTemplate = @"catalog/titles/series/%@/seasons/%@"; // seriesId, seasonId
NSString * const RSNetflixMethodProgramIdTemplate = @"catalog/titles/programs/%@"; // programId

NSString * const RSNetflixMethodTitleSimilarsTemplate = @"catalog/titles/%@/%@/similars"; // type, titleId

NSString * const RSNetflixMethodSearchPeople = @"catalog/people";
NSString * const RSNetflixMethodPersonIdTemplate = @"catalog/people/%@"; // personId

@end
