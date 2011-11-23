//
//  RSNetflixEngine.h
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 Rizwan Sattar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSNetflixAPIContext.h"
#import "RSNetflixAPIRequest.h"


@class RSNetflixEngine;


@protocol RSNetflixEngineDelegate <NSObject>

@optional

- (void)netflixEngine:(RSNetflixEngine *)engine requestSucceeded:(NSString *)identifier withResponse:(NSDictionary *)response;
- (void)netflixEngine:(RSNetflixEngine *)engine requestFailed:(NSString *)identifier withError:(NSError *)error;

- (void)netflixEngine:(RSNetflixEngine *)engine oAuthTokenRequestSucceededWithLoginUrlString:(NSString *)loginUrl forRequestId:(NSString *)requestId;

@end

@interface RSNetflixEngine : NSObject <RSNetflixAPIRequestDelegate> {
    
    RSNetflixAPIContext *apiContext;
    
    // Potentially for pooling our active connections
    NSMutableArray *activeURLConnections;
    
    // This is our default delegate which all requests call back to
    // In our implementation, we'll "proxy" the delegate callback
    // so that we can track the response ourselves first
    
    id<RSNetflixEngineDelegate> delegate;
}

@property(assign) id<RSNetflixEngineDelegate> delegate;

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext;

// Methods for making Protected (subscriber granted access) calls
- (NSString *)requestOAuthToken;
- (NSString *)requestOAuthTokenWithSuccessBlock:(void (^)(NSString *))successBlock errorBlock:(void (^)(NSError *))errorBlock;

- (NSString *)searchForTitlesMatchingTerm:(NSString*)term;
- (NSString *)searchForTitlesMatchingTerm:(NSString*)term withMaxResults:(NSInteger)maxResults andPageOffset:(NSInteger)pageOffset;


// Declaring REST method names as constants
extern NSString * const RSNetflixMethodRequestToken;

extern NSString * const RSNetflixMethodSearchCatalogTitles;
extern NSString * const RSNetflixMethodAutocompleteCatalogTitles;
extern NSString * const RSNetflixMethodRetrieveAllCatalogTitles;

extern NSString * const RSNetflixMethodTitleIdTemplate; // titleId
extern NSString * const RSNetflixMethodSeriesIdTemplate; // seriesId
extern NSString * const RSNetflixMethodSeasonIdTemplate; // seriesId, seasonId
extern NSString * const RSNetflixMethodProgramIdTemplate; // programId

extern NSString * const RSNetflixMethodTitleSimilarsTemplate; // type, titleId

extern NSString * const RSNetflixMethodSearchPeople;
extern NSString * const RSNetflixMethodPersonIdTemplate; // personId

@end
