//
//  RSNetflixAPIContext.h
//  RSNetflixEngine
//
//  Created by Rizwan on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSNetflixAPIContext : NSObject {
    
    NSString *consumerKey;
    NSString *sharedSecret;
    NSString *applicationName;
    
    NSString *RESTAPIEndPoint;
    
    NSString *oAuthRequestToken;
    NSString *oAuthRequestTokenSecret;
    
    NSURL *oAuthLoginUrlFragment;
}

- (id)initWithConsumerKey:(NSString *)inConsumerKey sharedSecret:(NSString *)inSharedSecret applicationName:(NSString *)inApplicationName;

@property(copy) NSString *consumerKey;
@property(copy) NSString *sharedSecret;
@property(copy) NSString *applicationName;
@property(copy) NSString *RESTAPIEndPoint;
// These should be set after receiving a proper response from oauth/request_token
@property(copy) NSString *oAuthRequestToken;
@property(copy) NSString *oAuthRequestTokenSecret;
@property(copy) NSURL *oAuthLoginUrlFragment;


/*
- (void)setConsumerKey:(NSString *)inConsumerKey;
- (NSString *)consumerKey;
- (void)setSharedSecret:(NSString *)inSharedSecret;
- (NSString *)sharedSecret;
- (void)setApplicationName:(NSString *)inApplicationName;
- (NSString *)applicationName;
- (void)setRESTAPIEndpoint:(NSString *)inRESTAPIEndpoint;
- (NSString *)RESTAPIEndpoint;
*/
- (NSString *)queryFromArguments:(NSDictionary *)arguments;
- (NSString *)signedQueryFromArguments:(NSDictionary *)arguments methodName:(NSString *)methodName httpMethod:(NSString *)httpMethod;
- (NSString *)loginUrlStringWithCallbackUrlString:(NSString *)callbackUrlString;
@end
