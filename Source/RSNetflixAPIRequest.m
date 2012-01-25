//
//  RSNetflixAPIRequest.m
//  RSNetflixEngine
//
//  Created by Rizwan on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixAPIRequest.h"



// Useful for retaining active requests
static NSMutableArray *activeRequests = nil;

@interface RSNetflixAPIRequest (PrivateMethods)

- (void)destroyBlocks;
// idea taken from Matt Gemmell: https://github.com/mattgemmell/MGTwitterEngine
// Though I didn't want to create a whole category on NSString
+ (NSString*)stringWithNewUUID;

@end

@implementation RSNetflixAPIRequest

@synthesize delegate;
@synthesize identifier;

+(void) initialize {
    activeRequests = [[NSMutableArray array] retain];
}

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

- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned httpMethod:(NSString *)httpMethod
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
    if([newArgs objectForKey:@"expand"] == nil) {
        [newArgs setObject:@"all" forKey:@"expand"];
    }
    
    NSString *query = nil;
    if(isSigned) {
        query = [apiContext signedQueryFromArguments:newArgs methodName:methodName httpMethod:httpMethod];
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
    
    // keep our retain count while we make the request
    [activeRequests addObject:self];
    
    return identifier;
}

- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned  httpMethod:(NSString *)httpMethod withSuccessBlock:(void (^)(NSDictionary *response))inSuccessBlock errorBlock:(void (^)(NSError *error))inErrorBlock
{
    // Save our successBlock and errorBlock for calling back later
    [successBlock release];
    successBlock = [inSuccessBlock copy];
    [errorBlock release];
    errorBlock = [inErrorBlock copy];
    // now call as usual
    return [self callAPIMethod:methodName arguments:arguments isSigned:isSigned httpMethod:httpMethod];
}

- (NSString *)callAPIURLString:(NSString *)urlString isSigned:(BOOL)isSigned httpMethod:(NSString *)httpMethod
{
    return [self callAPIURLString:urlString isSigned:isSigned httpMethod:httpMethod withSuccessBlock:nil errorBlock:nil];
}

- (NSString *)callAPIURLString:(NSString *)urlString isSigned:(BOOL)isSigned httpMethod:(NSString *)httpMethod withSuccessBlock:(RSNetflixAPIRequestSuccessBlock)inSuccessBlock errorBlock:(RSNetflixAPIRequestErrorBlock)inErrorBlock
{
    // Let's parse this url String and extract a http method
    NSURL *url = [NSURL URLWithString:urlString];
    if(url) {
        NSString *method = [url.path substringFromIndex:1];
        NSString *query = url.query;
        /*
        NSInteger indexOfSlashAfterHost = [urlString rangeOfString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(8, urlString.length-8)].location;
        NSString *urlBase = [NSString stringWithFormat:@"%@/",[urlString substringToIndex:indexOfSlashAfterHost]];
        */
        // Create arguments NSDictionary from query string
        NSMutableDictionary *arguments = nil;
        if(query) {
            arguments = [NSMutableDictionary dictionary];
            NSArray *pairs = [query componentsSeparatedByString:@"&"];
            for(NSInteger i=0; i<pairs.count; i++) {
                NSArray *keyAndValue = [[pairs objectAtIndex:i] componentsSeparatedByString:@"="];
                // "Un" escape the value, because we'll be later escaping it again
                [arguments setValue:[[keyAndValue objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                             forKey:[keyAndValue objectAtIndex:0]];
            }
        }
        return [self callAPIMethod:method arguments:arguments isSigned:isSigned httpMethod:httpMethod withSuccessBlock:inSuccessBlock errorBlock:inErrorBlock];
    }
    return nil;
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
    
    // now we are safe to be destroyed
    [activeRequests removeObject:self];
    
}

- (void)loader:(RSURLLoader *)loader didFailWithError:(NSError*)error
{
    // Notify delegate of failure
    [self notifyDelegateOfError:error];
    
    // now we are safe to be destroyed
    [activeRequests removeObject:self];
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

#pragma - Constant Declarations
// Declaring REST method names as constants
NSString * const RSNetflixAPIHttpMethodGet      = @"GET";
NSString * const RSNetflixAPIHttpMethodPut      = @"PUT";
NSString * const RSNetflixAPIHttpMethodPost     = @"POST";
NSString * const RSNetflixAPIHttpMethodDelete   = @"DELETE";

@end
