//
//  RSNetflixAPIRequest.h
//  RSNetflixEngine
//
//  Created by Rizwan on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSNetflixAPIContext.h"
#import "RSURLLoader.h"

// Protocol declaration

@class RSNetflixAPIRequest;

@protocol RSNetflixAPIRequestDelegate <NSObject>

@optional

- (void)netflixAPIRequest:(RSNetflixAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary;
- (void)netflixAPIRequest:(RSNetflixAPIRequest *)inRequest didFailWithError:(NSError *)inError;

@end

// Declare the block types so it's easy to refer to them as variables
typedef void (^RSNetflixAPIRequestSuccessBlock)(NSDictionary *);
typedef void (^RSNetflixAPIRequestErrorBlock)(NSError *);

// Actual class declaration

@interface RSNetflixAPIRequest : NSObject <RSURLLoaderDelegate> {
    RSURLLoader *urlLoader;
    RSNetflixAPIContext *apiContext;
    
    NSString *identifier;
    
    id<RSNetflixAPIRequestDelegate> delegate;
    
    RSNetflixAPIRequestSuccessBlock successBlock;
    RSNetflixAPIRequestErrorBlock errorBlock;
}

@property(assign) id<RSNetflixAPIRequestDelegate> delegate;
@property(readonly) NSString *identifier;

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext;
- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned httpMethod:(NSString *)httpMethod;
- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned httpMethod:(NSString *)httpMethod withSuccessBlock:(RSNetflixAPIRequestSuccessBlock)successBlock errorBlock:(RSNetflixAPIRequestErrorBlock)errorBlock;
// Many Netflix responses are in the form of partial urls 
// (without parameters and signing) that refer to items, so 
// let's make it easy to request those urls
- (NSString *)callAPIURLString:(NSString *)urlString isSigned:(BOOL)isSigned httpMethod:(NSString *)httpMethod;
- (NSString *)callAPIURLString:(NSString *)urlString isSigned:(BOOL)isSigned httpMethod:(NSString *)httpMethod withSuccessBlock:(RSNetflixAPIRequestSuccessBlock)successBlock errorBlock:(RSNetflixAPIRequestErrorBlock)errorBlock;

#pragma - Constants for HTTP Methods

extern NSString * const RSNetflixAPIHttpMethodGet;
extern NSString * const RSNetflixAPIHttpMethodPut;
extern NSString * const RSNetflixAPIHttpMethodPost;
extern NSString * const RSNetflixAPIHttpMethodDelete;

@end