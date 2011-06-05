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
    
    NSString *RESTAPIEndpoint;
}

- (id)initWithConsumerKey:(NSString *)inConsumerKey sharedSecret:(NSString *)inSharedSecret applicationName:(NSString *)inApplicationName;

- (void)setConsumerKey:(NSString *)inConsumerKey;
- (NSString *)consumerKey;
- (void)setSharedSecret:(NSString *)inSharedSecret;
- (NSString *)sharedSecret;
- (void)setApplicationName:(NSString *)inApplicationName;
- (NSString *)applicationName;
- (void)setRESTAPIEndpoint:(NSString *)inRESTAPIEndpoint;
- (NSString *)RESTAPIEndpoint;

- (NSString *)queryFromArguments:(NSDictionary *)arguments;
- (NSString *)signedQueryFromArguments:(NSDictionary *)arguments methodName:(NSString *)methodName httpMethod:(NSString *)httpMethod;
@end
