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

@interface RSNetflixEngine : NSObject <RSNetflixAPIRequestDelegate> {
    
    RSNetflixAPIContext *apiContext;
    
    // Potentially for pooling our active connections
    NSMutableArray *activeURLConnections;
    
    // This is our default delegate which all requests call back to
    // In our implementation, we'll "proxy" the delegate callback
    // so that we can track the response ourselves first
    
    id<RSNetflixAPIRequestDelegate> delegate;
}

@property(assign) id<RSNetflixAPIRequestDelegate> delegate;

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext;

- (void)searchForTitlesMatchingTerm:(NSString*)term;
- (void)searchForTitlesMatchingTerm:(NSString*)term withMaxResults:(NSInteger)maxResults andPageOffset:(NSInteger)pageOffset;


// Declaring REST method names as constants
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
