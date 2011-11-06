//
//  RSNetflixEngine.m
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixEngine.h"

@implementation RSNetflixEngine

@synthesize delegate;

- (void)dealloc
{
    [apiContext release];
    
    [activeURLConnections release];
    
    [super dealloc];
}

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext
{
    if ((self = [super init])) {
        apiContext = [inAPIContext retain];
        
        activeURLConnections = [[NSMutableArray array] retain];
    }
    return self;
}



// Declaring REST method names as constants
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
