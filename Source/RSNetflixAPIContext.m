//
//  RSNetflixAPIContext.m
//  RSNetflixEngine
//
//  Created by Rizwan on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixAPIContext.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "Base64Transcoder.h"


#define kDefaultNetflixRESTAPIEndpoint		@"http://api.netflix.com/"

@interface RSNetflixAPIContext (PrivateMethods)

+ (NSString *)signedQueryFromArguments:(NSDictionary *)arguments baseURL:(NSString *)baseURL method:(NSString *)method consumerKey:(NSString *)consumerKey sharedSecret:(NSString *)sharedSecret token:(NSString *)authorizedToken tokenSecret:(NSString *)authorizedTokenSecret httpMethod:(NSString *)httpMethod;
+ (NSString *)queryFromArguments:(NSDictionary *)arguments;

@end

@implementation RSNetflixAPIContext

@synthesize consumerKey;
@synthesize sharedSecret;
@synthesize applicationName;
@synthesize RESTAPIEndPoint;
@synthesize userLoginCallbackUrl;
@synthesize oAuthRequestToken;
@synthesize oAuthRequestTokenSecret;
@synthesize oAuthAccessToken;
@synthesize oAuthAccessTokenSecret;
@synthesize userId;
@synthesize oAuthLoginUrlFragment;

- (void)dealloc
{
    [consumerKey release];
    [sharedSecret release];
    [applicationName release];
    [RESTAPIEndPoint release];
    [userLoginCallbackUrl release];
    [oAuthRequestToken release];
    [oAuthRequestTokenSecret release];
    [oAuthAccessToken release];
    [oAuthAccessTokenSecret release];
    [userId release];
    [oAuthLoginUrlFragment release];
    
    [super dealloc];
}

- (id)initWithConsumerKey:(NSString *)inConsumerKey sharedSecret:(NSString *)inSharedSecret applicationName:(NSString *)inApplicationName
{
    if ((self = [super init])) {
        self.consumerKey = inConsumerKey;
        self.sharedSecret = inSharedSecret;
        self.applicationName = inApplicationName;
        
        // Set our Request tokens to "" because we only set them
        // if we're in the middle of retrieving access tokens
        self.oAuthRequestToken = @"";
        self.oAuthRequestTokenSecret = @"";
        
        // Set our access to "" so signed requests still work
        self.oAuthAccessToken = @"";
        self.oAuthAccessTokenSecret = @"";
        self.userId = @"";
        
        self.RESTAPIEndPoint = kDefaultNetflixRESTAPIEndpoint;
        self.userLoginCallbackUrl = @"";
        self.oAuthLoginUrlFragment = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.consumerKey = [decoder decodeObjectForKey:@"consumerKey"];
        self.sharedSecret = [decoder decodeObjectForKey:@"sharedSecret"];
        self.applicationName = [decoder decodeObjectForKey:@"applicationName"];
        
        self.oAuthRequestToken = [decoder decodeObjectForKey:@"oAuthRequestToken"];
        self.oAuthRequestTokenSecret = [decoder decodeObjectForKey:@"oAuthRequestTokenSecret"];
        
        self.oAuthAccessToken = [decoder decodeObjectForKey:@"oAuthAccessToken"];
        self.oAuthAccessTokenSecret = [decoder decodeObjectForKey:@"oAuthAccessTokenSecret"];
        self.userId = [decoder decodeObjectForKey:@"userId"];
        
        self.RESTAPIEndPoint = [decoder decodeObjectForKey:@"RESTAPIEndPoint"];
        self.userLoginCallbackUrl = [decoder decodeObjectForKey:@"userLoginCallbackUrl"];
        if([decoder containsValueForKey:@"oAuthLoginUrlFragment"]) {
            self.oAuthLoginUrlFragment = [decoder decodeObjectForKey:@"oAuthLoginUrlFragment"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:consumerKey forKey:@"consumerKey"];
    [encoder encodeObject:sharedSecret forKey:@"sharedSecret"];
    [encoder encodeObject:applicationName forKey:@"applicationName"];
    
    [encoder encodeObject:oAuthRequestToken forKey:@"oAuthRequestToken"];
    [encoder encodeObject:oAuthRequestTokenSecret forKey:@"oAuthRequestTokenSecret"];
    
    [encoder encodeObject:oAuthAccessToken forKey:@"oAuthAccessToken"];
    [encoder encodeObject:oAuthAccessTokenSecret forKey:@"oAuthAccessTokenSecret"];
    [encoder encodeObject:userId forKey:@"userId"];
    
    [encoder encodeObject:RESTAPIEndPoint forKey:@"RESTAPIEndPoint"];
    [encoder encodeObject:userLoginCallbackUrl forKey:@"userLoginCallbackUrl"];
    if(oAuthLoginUrlFragment != nil) {
        [encoder encodeObject:oAuthLoginUrlFragment forKey:@"oAuthLoginUrlFragment"];
    }
}

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


//generate md5 hash from string
// From: http://www.saobart.com/md5-has-in-objective-c/
+ (NSString *) returnMD5Hash:(NSString*)concat {
    const char *concat_str = [concat UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
    
}

- (NSString *)signedQueryFromArguments:(NSDictionary *)arguments methodName:(NSString *)methodName httpMethod:(NSString *)httpMethod
{
    NSString *tokenToUse = oAuthAccessToken;
    NSString *tokenSecretToUse = oAuthAccessTokenSecret;
    if([methodName isEqualToString:@"oauth/access_token"]) {
        tokenToUse = oAuthRequestToken;
        // In case this is our special case access_token call, our signature is signed by:
        // sharedSecret&requestTokenSecret
        // instead of:
        // sharedSecret&authorizedTokenSecret
        tokenSecretToUse = oAuthRequestTokenSecret;
    }
    return [RSNetflixAPIContext signedQueryFromArguments:arguments baseURL:RESTAPIEndPoint method:methodName consumerKey:consumerKey sharedSecret:sharedSecret token:tokenToUse tokenSecret:tokenSecretToUse httpMethod:httpMethod];
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


- (NSString *)constructUserLoginUrlString
{
    NSMutableString *loginUrl = [NSMutableString stringWithString:@""];
    
    if(oAuthLoginUrlFragment && userLoginCallbackUrl) {
        NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionary];
        // Add our existing params here (make sure we insert everything in params dictionary already url encoded)
        [paramsDictionary setObject:[self urlEncodedStringFromString:applicationName] forKey:@"application_name"];
        [paramsDictionary setObject:[self urlEncodedStringFromString:consumerKey] forKey:@"oauth_consumer_key"];
        [paramsDictionary setObject:[self urlEncodedStringFromString:oAuthRequestToken] forKey:@"oauth_token"];
        [paramsDictionary setObject:[self urlEncodedStringFromString:userLoginCallbackUrl] forKey:@"oauth_callback"];
        
        NSString *existingParamString = oAuthLoginUrlFragment.query;
        if([existingParamString length] > 0) {
            // Separate into & bits first
            NSArray *pairs = [existingParamString componentsSeparatedByString:@"&"];
            for (NSInteger i = 0; i < pairs.count; i++) {
                NSArray *split = [[pairs objectAtIndex:i] componentsSeparatedByString:@"="];
                // These objects are already url encoded, so just set them into the dictionary
                [paramsDictionary setObject:[split objectAtIndex:1] forKey:[split objectAtIndex:0]];
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
            // key and value are already url encoded, so just concatenate
            [parametersString appendFormat: @"%@=%@", key, value];
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

+ (NSString *)signedQueryFromArguments:(NSDictionary *)arguments baseURL:(NSString *)baseURL method:(NSString *)method consumerKey:(NSString *)consumerKey sharedSecret:(NSString *)sharedSecret token:(NSString *)token tokenSecret:(NSString *)tokenSecret httpMethod:(NSString *)httpMethod
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
    NSString *nonce = [RSNetflixAPIContext returnMD5Hash:[NSString stringWithFormat:@"%d",timestamp]];
    [newArgs setObject:nonce forKey:@"oauth_nonce"];
    //[newArgs setObject:[NSString stringWithFormat:@"%d",timestamp] forKey:@"oauth_nonce"];
    //[newArgs setObject:@"1234" forKey:@"oauth_nonce"];
    
    // oauth_signature_method
    [newArgs setObject:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
    
    // oauth_version - (optional) if you include this, you must set it to "1.0" (which is also the default)
    [newArgs setObject:@"1.0" forKey:@"oauth_version"];
    
    // If we pass in oauth_token (and sign with it), our quota for requests is much higher
    if([token length] && [tokenSecret length]) {
        [newArgs setObject:token forKey:@"oauth_token"];
    }
    
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
    NSString *signature = [RSNetflixAPIContext HMAC_SHA1SignatureForText:baseString usingSecret:[NSString stringWithFormat:@"%@&%@",sharedSecret,tokenSecret]];
    
    
    NSString *queryString = [sortedQueryString stringByAppendingString:[NSString stringWithFormat:@"&oauth_signature=%@",oAuthEscape(signature)]];
    return queryString;
}

@end
