//
//  RSNetflixEngine.m
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixEngine.h"
#import <CommonCrypto/CommonHMAC.h>
#import "Base64Transcoder.h"
#import "RSURLLoader.h"

#define kDefaultNetflixRESTAPIEndpoint		@"http://api.netflix.com/"

@implementation RSNetflixEngine
- (void)dealloc
{
    [consumerKey release];
    [sharedSecret release];
    [applicationName release];
    [RESTAPIEndpoint release];
    
    [activeURLConnections release];
    
    [super dealloc];
}


- (id)initWithConsumerKey:(NSString *)inConsumerKey sharedSecret:(NSString *)inSharedSecret applicationName:(NSString *)inApplicationName
{
    if ((self = [super init])) {
        consumerKey = [inConsumerKey copy];
        sharedSecret = [inSharedSecret copy];
        applicationName = [inApplicationName copy];
        
        RESTAPIEndpoint = kDefaultNetflixRESTAPIEndpoint;
        
        activeURLConnections = [[NSMutableArray array] retain];
    }
    return self;
}


- (void)setConsumerKey:(NSString *)inConsumerKey
{
    NSString *tmp = consumerKey;
    consumerKey = [inConsumerKey copy];
    [tmp release];
}

- (NSString *)consumerKey
{
    return consumerKey;
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
    NSString *query = nil;
    if(isSigned) {
        query = [RSNetflixEngine signedQueryFromArguments:arguments baseURL:RESTAPIEndpoint method:methodName consumerKey:consumerKey sharedSecret:sharedSecret httpMethod:@"GET"];
    } else {
        query = [RSNetflixEngine queryFromArguments:arguments];
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", RESTAPIEndpoint, methodName, query];
    RSURLLoader *connection = [[RSURLLoader alloc] initWithURL:urlString delegate:self];
    
    [activeURLConnections addObject:connection];
    [connection start];
    
    [connection release]; // because we alloc-inited and added to urlconnections
}

NSString *oAuthEscape(NSString *string)
{
    /*
     string = [string stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
     // Get some of the ones that the default escaper missed
     string = [string stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
     string = [string stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"];
     string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
     string = [string stringByReplacingOccurrencesOfString:@"," withString:@"%28"];
     string = [string stringByReplacingOccurrencesOfString:@")" withString:@"%29"];
     */
    // http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
    string = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                   NULL,
                                                                   (CFStringRef)string,
                                                                   NULL,
                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                   kCFStringEncodingUTF8 );
    return string;
}



+ (NSString *)HMAC_SHA1SignatureForText:(NSString *)inText usingSecret:(NSString *)inSecret {
	NSData *secretData = [inSecret dataUsingEncoding:NSUTF8StringEncoding];
	NSData *textData = [inText dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
    
	CCHmacContext hmacContext;
	bzero(&hmacContext, sizeof(CCHmacContext));
    CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
    CCHmacUpdate(&hmacContext, textData.bytes, textData.length);
    CCHmacFinal(&hmacContext, result);
    
	//Base64 Encoding
	char base64Result[32];
	size_t theResultLength = 32;
	Base64EncodeData(result, 20, base64Result, &theResultLength);
	NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
	NSString *base64EncodedResult = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
    
	return base64EncodedResult;
}

+ (NSString *)signedQueryFromArguments:(NSDictionary *)arguments baseURL:(NSString *)baseURL method:(NSString *)method consumerKey:(NSString *)consumerKey sharedSecret:(NSString *)sharedSecret httpMethod:(NSString *)httpMethod
{
    // Add our "authentication" parameters to the arguments
    NSMutableDictionary *newArgs = [NSMutableDictionary dictionaryWithDictionary:arguments];
	
    // oauth_consumer_key - your application's public key, listed simply as "key" on your developer profile
    if ([consumerKey length]) {
		[newArgs setObject:consumerKey forKey:@"oauth_consumer_key"];
	}
    
    // timestamp - he number of seconds elapsed since midnight, 1 January 1970. Be sure this is within ten minutes of the real time.
    NSInteger timestamp = (NSInteger)[[NSDate date] timeIntervalSince1970];
    [newArgs setObject:[NSString stringWithFormat:@"%d",timestamp] forKey:@"oauth_timestamp"];
    
    
    // oauth_nonce - a random string of characters that differs from call to call (this helps to prevent replay attacks)
    // For now, let's just use our timestamp
    [newArgs setObject:[NSString stringWithFormat:@"%d",timestamp] forKey:@"oauth_nonce"];
    //[newArgs setObject:@"1234" forKey:@"oauth_nonce"];
    
    // oauth_signature_method
    [newArgs setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
    
    // oauth_version - (optional) if you include this, you must set it to "1.0" (which is also the default)
    [newArgs setObject:@"1.0" forKey:@"oauth_version"];
    
    // Generate sorted queryString
    NSArray *sortedParameterKeys = [[newArgs allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *parameterKey;
    NSString *value;
    NSString *sortedQueryStringForBaseString = @"";
    NSString *sortedQueryString = @"";
    for (NSUInteger i=0; i < [sortedParameterKeys count]; i++) {
        parameterKey = [sortedParameterKeys objectAtIndex:i];
        value = [newArgs objectForKey:parameterKey];
        
        sortedQueryStringForBaseString = [sortedQueryStringForBaseString stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@",(i > 0 ? @"&" : @""),parameterKey,value]];
        sortedQueryString = [sortedQueryString stringByAppendingString:[NSString stringWithFormat:@"%@%@=%@",(i > 0 ? @"&" : @""),parameterKey,oAuthEscape(value)]];
    }
    NSString *encodedSortedQueryString = oAuthEscape(sortedQueryString);
    
    // Generate base string
    NSString *encodedBaseURLAndMethod = oAuthEscape([NSString stringWithFormat:@"%@%@", baseURL, method]);
    
    NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@",httpMethod,encodedBaseURLAndMethod,encodedSortedQueryString];
    
    // Create signature
    NSString *signature = [RSNetflixEngine HMAC_SHA1SignatureForText:baseString usingSecret:[NSString stringWithFormat:@"%@&",sharedSecret]];
    
    
    NSString *queryString = [sortedQueryString stringByAppendingString:[NSString stringWithFormat:@"&oauth_signature=%@",oAuthEscape(signature)]];
    /*
    // Go through NSDictionary keys and convert to array
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:[[arguments allKeys] count]];
    for (NSString *key in arguments) {
        NSString *value = [arguments objectForKey:key];
        [parameters addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
    }
    return [parameters componentsJoinedByString:@"&"];
     */
    /*
    NSString *finalURL = [NSString stringWithFormat:@"%@%@?%@",baseURL, method, queryString]; 
    NSLog(@"Final signed url: %@",finalURL);
    return finalURL;
     */
    return queryString;
}

+ (NSString *)queryFromArguments:(NSDictionary *)arguments
{
    // Go through NSDictionary keys and convert to array
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:[[arguments allKeys] count]];
    for (NSString *key in arguments) {
        NSString *value = [arguments objectForKey:key];
        [parameters addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
    }
    return [parameters componentsJoinedByString:@"&"];
}

#pragma mark -
#pragma mark RSURLLoader delegate methods


- (void)loader:(RSURLLoader *)loader didFinishWithStatusCode:(NSInteger)statusCode data:(NSData *)data
{
    NSString *rawString = @"";
    if([data length] > 0) {
        // Pull the data out
        rawString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSLog(@"\nStatus Code: %d\n%@",statusCode,rawString);
    [rawString release];
    [activeURLConnections removeObject:loader];
}
- (void)loader:(RSURLLoader *)loader didFailWithError:(NSError*)error
{
    [activeURLConnections removeObject:loader];
}

@end
