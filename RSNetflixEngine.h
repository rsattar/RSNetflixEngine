//
//  RSNetflixEngine.h
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSNetflixAPIContext.h"
#import "RSNetflixAPIRequest.h"

@interface RSNetflixEngine : NSObject {
    
    RSNetflixAPIContext *apiContext;
    
    // Potentially for pooling our active connections
    NSMutableArray *activeURLConnections;
}

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext;



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
