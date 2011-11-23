//
//  RSNetflixAPIContext.m
//  RSNetflixEngine
//
//  Created by Rizwan on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixAPIContext.h"
#import <CommonCrypto/CommonHMAC.h>
#import "Base64Transcoder.h"


#define kDefaultNetflixRESTAPIEndpoint		@"http://api.netflix.com/"

@interface RSNetflixAPIContext (PrivateMethods)

+ (NSString *)signedQueryFromArguments:(NSDictionary *)arguments baseURL:(NSString *)baseURL method:(NSString *)method consumerKey:(NSString *)consumerKey sharedSecret:(NSString *)sharedSecret httpMethod:(NSString *)httpMethod;
+ (NSString *)queryFromArguments:(NSDictionary *)arguments;

@end

@implementation RSNetflixAPIContext

@synthesize consumerKey;
@synthesize sharedSecret;
@synthesize applicationName;
@synthesize RESTAPIEndPoint;
@synthesize oAuthRequestToken;
@synthesize oAuthRequestTokenSecret;
@synthesize oAuthLoginUrlFragment;

- (void)dealloc
{
    [consumerKey release];
    [sharedSecret release];
    [applicationName release];
    [RESTAPIEndPoint release];
    [oAuthRequestToken release];
    [oAuthRequestTokenSecret release];
    
    [super dealloc];
}


- (id)initWithConsumerKey:(NSString *)inConsumerKey sharedSecret:(NSString *)inSharedSecret applicationName:(NSString *)inApplicationName
{
    if ((self = [super init])) {
        consumerKey = [inConsumerKey copy];
        sharedSecret = [inSharedSecret copy];
        applicationName = [inApplicationName copy];
        
        RESTAPIEndPoint = kDefaultNetflixRESTAPIEndpoint;
    }
    return self;
}

/*
#pragma mark -
#pragma Property getters and setters

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

- (void)setSharedSecret:(NSString *)inSharedSecret
{
    NSString *tmp = sharedSecret;
    sharedSecret = [inSharedSecret copy];
    [tmp release];
}

- (NSString *)sharedSecret
{
    return sharedSecret;
}

- (void)setApplicationName:(NSString *)inApplicationName
{
    NSString *tmp = applicationName;
    applicationName = [inApplicationName copy];
    [tmp release];
}

- (NSString *)applicationName
{
    return applicationName;
}

- (void)setRESTAPIEndpoint:(NSString *)inRESTAPIEndpoint
{
    NSString *tmp = RESTAPIEndpoint;
    RESTAPIEndpoint = [inRESTAPIEndpoint copy];
    [tmp release];
}

- (NSString *)RESTAPIEndpoint
{
    return RESTAPIEndpoint;
}
*/
#pragma mark -
#pragma Query Building and Signing

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

- (NSString *)signedQueryFromArguments:(NSDictionary *)arguments methodName:(NSString *)methodName httpMethod:(NSString *)httpMethod
{
    return [RSNetflixAPIContext signedQueryFromArguments:arguments baseURL:RESTAPIEndPoint method:methodName consumerKey:consumerKey sharedSecret:sharedSecret httpMethod:httpMethod];
}

- (NSString *)queryFromArguments:(NSDictionary *)arguments
{
    return [RSNetflixAPIContext queryFromArguments:arguments];
}

- (NSString *)urlEncodedStringFromString:(NSString *)starting
{
    // From http://stackoverflow.com/questions/2590545/urlencoding-a-string-with-objective-c
    NSString *encoded = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                            NULL,
                                                                            (CFStringRef)starting,
                                                                            NULL,
                                                                            (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                            kCFStringEncodingUTF8 );
    return encoded;
}


- (NSString *)loginUrlStringWithCallbackUrlString:(NSString *)callbackUrlString
{
    NSMutableString *loginUrl = [NSMutableString stringWithString:@""];
    
    if(oAuthLoginUrlFragment && callbackUrlString) {
        NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
        // Add our existing params here
        [paramsDictionary setObject:[self urlEncodedStringFromString:applicationName] forKey:@"application_name"];
        [paramsDictionary setObject:consumerKey forKey:@"oauth_consumer_key"];
        [paramsDictionary setObject:oAuthRequestToken forKey:@"oauth_token"];
        [paramsDictionary setObject:[self urlEncodedStringFromString:callbackUrlString] forKey:@"oauth_callback"];
        
        NSString *existingParamString = oAuthLoginUrlFragment.query;
        if([existingParamString length] > 0) {
            // Separate into & bits first
            NSArray *pairs = [existingParamString componentsSeparatedByString:@"&"];
            for (NSInteger i = 0; i < pairs.count; i++) {
                NSArray *split = [[pairs objectAtIndex:i] componentsSeparatedByString:@"="];
                [paramsDictionary setObject:[self urlEncodedStringFromString:[split objectAtIndex:1]] forKey:[split objectAtIndex:0]];
            }
        }
        
        // params dictionary is full, let's build the string
        NSMutableString *parametersString = [NSMutableString stringWithString:@""];
        BOOL parameterAdded = NO;
        for (NSString *key in paramsDictionary) {
            NSString *value = [paramsDictionary objectForKey: key];
            if(parameterAdded) {
                [parametersString appendString:@"&"];
            } else {
                [parametersString appendString:@"?"];
            }
            [parametersString appendFormat: @"%@=%@", [self urlEncodedStringFromString:key], [self urlEncodedStringFromString:value]];
            parameterAdded = YES;
        }
        
        // now reconstruct login url with new parameter string
        [loginUrl appendFormat:@"%@://",oAuthLoginUrlFragment.scheme];
        [loginUrl appendString:oAuthLoginUrlFragment.host];
        [loginUrl appendString:oAuthLoginUrlFragment.path];
        [loginUrl appendString:parametersString];
    }
    
    return loginUrl;
}


@end

@implementation RSNetflixAPIContext (PrivateMethods)


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
    NSString *signature = [RSNetflixAPIContext HMAC_SHA1SignatureForText:baseString usingSecret:[NSString stringWithFormat:@"%@&",sharedSecret]];
    
    
    NSString *queryString = [sortedQueryString stringByAppendingString:[NSString stringWithFormat:@"&oauth_signature=%@",oAuthEscape(signature)]];
    return queryString;
}

@end
