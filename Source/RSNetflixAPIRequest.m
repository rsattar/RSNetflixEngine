//
//  RSNetflixAPIRequest.m
//  RSNetflixEngine
//
//  Created by Rizwan on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixAPIRequest.h"


@implementation RSNetflixAPIRequest

@synthesize delegate;

- (void)dealloc
{
    [apiContext release];
    
    [super dealloc];
}

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext
{
    if ((self = [super init])) {
        apiContext = [inAPIContext retain];
        urlLoader = nil;
    }
    return self;
}

- (void)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned 
{
    
    // combine the parameters 
    /*
     NSMutableDictionary *newArgs = arguments ? [NSMutableDictionary dictionaryWithDictionary:arguments] : [NSMutableDictionary dictionary];
     [newArgs setObject:inMethodName forKey:@"method"];	
     NSString *query = [context signedQueryFromArguments:newArgs];
     NSString *URLString = [NSString stringWithFormat:@"%@?%@", RESTAPIEndpoint, query];
     */
    //"v=2.0&output=json&expands=all"
    NSMutableDictionary *newArgs = arguments ? [NSMutableDictionary dictionaryWithDictionary:arguments] : [NSMutableDictionary dictionary];
    if([newArgs objectForKey:@"v"] == nil) {
        [newArgs setObject:@"2.0" forKey:@"v"];
    }
    if([newArgs objectForKey:@"output"] == nil) {
        [newArgs setObject:@"json" forKey:@"output"];
    }
    if([newArgs objectForKey:@"expands"] == nil) {
        [newArgs setObject:@"all" forKey:@"expands"];
    }
    
    NSString *query = nil;
    if(isSigned) {
        query = [apiContext signedQueryFromArguments:newArgs methodName:methodName httpMethod:@"GET"];
    } else {
        query = [apiContext queryFromArguments:newArgs];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", [apiContext RESTAPIEndpoint], methodName, query];
    NSLog(@"URL Request: %@",urlString);
    [urlLoader release];
    urlLoader = [[RSURLLoader alloc] initWithURL:urlString delegate:self];
    [urlLoader start];
}

- (void)notifyDelegateOfError:(NSError *)error
{
    if([delegate respondsToSelector:@selector(netflixAPIRequest:didFailWithError:)]) {
        [delegate netflixAPIRequest:self didFailWithError:error];
    }
}

#pragma mark -
#pragma mark RSURLLoader delegate methods


- (void)loader:(RSURLLoader *)loader didFinishWithStatusCode:(NSInteger)statusCode data:(NSData *)data
{
    /*
    NSString *rawString = @"";
    if([data length] > 0) {
        // Pull the data out
        rawString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSLog(@"\nStatus Code: %d\n%@",statusCode,rawString);
    [rawString release];
    */
    //NSMutableDictionary *responseDictionary = [NSMutableDictionary dictionary];
    NSError* error = nil;
    NSDictionary* responseDictionary = [NSJSONSerialization 
                                        JSONObjectWithData:data //1
                                        options:kNilOptions 
                                        error:&error];
    if(error == nil) {
        
        // Notify delegate of success
        if([delegate respondsToSelector:@selector(netflixAPIRequest:didCompleteWithResponse:)]) {
            [delegate netflixAPIRequest:self didCompleteWithResponse:responseDictionary];
        }
    } else {
        [self notifyDelegateOfError:error];
    }
    
}

- (void)loader:(RSURLLoader *)loader didFailWithError:(NSError*)error
{
    // Notify delegate of failure
    [self notifyDelegateOfError:error];
}

@end
