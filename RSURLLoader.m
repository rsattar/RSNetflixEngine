//
//  RSURLLoader.m
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSURLLoader.h"


@implementation RSURLLoader

- (id)initWithURL:(NSString *)inURL delegate:(id)inDelegate
{
    if ((self = [super init])) {
        
        urlRequest = [[NSURLRequest requestWithURL:[NSURL URLWithString:inURL]] retain];
        connection = [[NSURLConnection connectionWithRequest:urlRequest delegate:self] retain];
        
        receivedData = [[NSMutableData data] retain];
        statusCode = 0;
        
        delegate = inDelegate;
        
    }
    return self;
}

- (void)dealloc {
    
    [urlRequest release];
    [connection release];
    [receivedData release];
    [contextObj release];
    statusCode = 0;
    delegate = nil;
    
    [super dealloc];
}

- (void)start
{
    [connection start];
}

- (void)setContext:(NSObject *)context
{
    NSObject *tmp = contextObj;
    contextObj = [context copy];
    [tmp release];
}

- (NSObject *)context
{
    return [contextObj copy];
}


#pragma -
#pragma NSURLConnection Delegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection did finish loading");
    /*
    NSString *dataString = nil;
    if([receivedData length] > 0) {
        // Pull the data out
        dataString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",dataString);
        [dataString release];
    }
    */
    if(statusCode == 200) {
        // Great success! is NAIS!
        
    } else {
        // Didn't receive a 200 Response
    }
    
    if([delegate respondsToSelector:@selector(loader:didFinishWithStatusCode:data:)]) {
        [delegate loader:self didFinishWithStatusCode:statusCode data:receivedData];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"Connection did receive response %@", httpResponse);
    statusCode = httpResponse.statusCode;
    
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection did fail with error %@", [error description]);
    
    if([delegate respondsToSelector:@selector(loader:didFailWithError:)]) {
        
        [delegate loader:self didFailWithError:error];
    }
}

@end
