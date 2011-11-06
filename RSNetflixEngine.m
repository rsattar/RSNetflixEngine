//
//  RSNetflixEngine.m
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixEngine.h"



@interface RSNetflixEngine (PrivateMethods)

// Delegate methods
- (BOOL) isValidDelegateForSelector:(SEL)selector;

@end



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

#pragma mark -
#pragma mark Catalog methods


- (void)searchForTitlesMatchingTerm:(NSString*)term
{
    [self searchForTitlesMatchingTerm:term withMaxResults:-1 andPageOffset:0];
}

- (void)searchForTitlesMatchingTerm:(NSString*)term withMaxResults:(NSInteger)maxResults andPageOffset:(NSInteger)pageOffset
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
    [request callAPIMethod:RSNetflixMethodSearchCatalogTitles arguments:arguments isSigned:YES];
    
    [activeURLConnections addObject:request];
}



#pragma mark -
#pragma mark API Request delegate

- (void)netflixAPIRequest:(RSNetflixAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    if([activeURLConnections containsObject:inRequest]) {
        [activeURLConnections removeObject:inRequest];
    }
    
    if ([self isValidDelegateForSelector:@selector(netflixAPIRequest:didCompleteWithResponse:)])
        [delegate netflixAPIRequest:inRequest didCompleteWithResponse:inResponseDictionary];
}

- (void)netflixAPIRequest:(RSNetflixAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    if([activeURLConnections containsObject:inRequest]) {
        [activeURLConnections removeObject:inRequest];
    }
    
    if ([self isValidDelegateForSelector:@selector(netflixAPIRequest:didFailWithError:)])
        [delegate netflixAPIRequest:inRequest didFailWithError:inError];
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
