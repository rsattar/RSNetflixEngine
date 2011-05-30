//
//  RSNetflixEngine.h
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSNetflixEngine : NSObject {
    
    NSString *consumerKey;
    NSString *sharedSecret;
    NSString *applicationName;
    
    NSString *RESTAPIEndpoint;
    
    NSMutableArray *activeURLConnections;
}

- (id)initWithConsumerKey:(NSString *)inConsumerKey sharedSecret:(NSString *)inSharedSecret applicationName:(NSString *)inApplicationName;

- (void)setConsumerKey:(NSString *)inConsumerKey;
- (NSString *)consumerKey;

- (void)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned;

+ (NSString *)signedQueryFromArguments:(NSDictionary *)arguments baseURL:(NSString *)baseURL method:(NSString *)method consumerKey:(NSString *)consumerKey sharedSecret:(NSString *)sharedSecret httpMethod:(NSString *)httpMethod;
+ (NSString *)queryFromArguments:(NSDictionary *)arguments;

@end
