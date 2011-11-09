//
//  RSNetflixAPIRequest.m
//  RSNetflixEngine
//
//  Created by Rizwan on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixAPIRequest.h"


@interface RSNetflixAPIRequest (PrivateMethods)

- (void)destroyBlocks;
// idea taken from Matt Gemmell: https://github.com/mattgemmell/MGTwitterEngine
// Though I didn't want to create a whole category on NSString
+ (NSString*)stringWithNewUUID;

@end

@implementation RSNetflixAPIRequest

@synthesize delegate;
@synthesize identifier;

- (void)dealloc
{
    [self destroyBlocks];
    [apiContext release];
    [identifier release];
    delegate = nil;
    [super dealloc];
}

- (void)destroyBlocks
{
    [successBlock release];
    successBlock = nil;
    [errorBlock release];
    errorBlock = nil;
}

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext
{
    if ((self = [super init])) {
        apiContext = [inAPIContext retain];
        urlLoader = nil;
        identifier = nil;
    }
    return self;
}

- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned 
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", apiContext.RESTAPIEndPoint, methodName, query];
    NSLog(@"URL Request: %@",urlString);
    [urlLoader release];
    urlLoader = [[RSURLLoader alloc] initWithURL:urlString delegate:self];
    [urlLoader start];
    
    NSString *tmpIdentifier = identifier;
    identifier = [[RSNetflixAPIRequest stringWithNewUUID] retain];
    [tmpIdentifier release];
    tmpIdentifier = nil;
    
    return identifier;
}

- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned withSuccessBlock:(void (^)(NSDictionary *response))inSuccessBlock errorBlock:(void (^)(NSError *error))inErrorBlock
{
    // Save our successBlock and errorBlock for calling back later
    [successBlock release];
    successBlock = [inSuccessBlock copy];
    [errorBlock release];
    errorBlock = [inErrorBlock copy];
    // now call as usual
    return [self callAPIMethod:methodName arguments:arguments isSigned:isSigned];
}

- (void)notifyDelegateOfError:(NSError *)error
{
    if([delegate respondsToSelector:@selector(netflixAPIRequest:didFailWithError:)]) {
        [delegate netflixAPIRequest:self didFailWithError:error];
    }
    // Notify via blocks, if we 'ave one
    if(errorBlock) {
        errorBlock(error);
    }
    [self destroyBlocks];
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
        // Notify via blocks, if we 'ave one
        if(successBlock) {
            successBlock(responseDictionary);
        }
        [self destroyBlocks];
    } else {
        [self notifyDelegateOfError:error];
    }
    
}

- (void)loader:(RSURLLoader *)loader didFailWithError:(NSError*)error
{
    // Notify delegate of failure
    [self notifyDelegateOfError:error];
}

#pragma mark -
#pragma mark PrivateMethods implementation

+ (NSString*)stringWithNewUUID
{
    // Create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the string representation of the UUID
    NSString *newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
}

@end
