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
- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned;
- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned withSuccessBlock:(RSNetflixAPIRequestSuccessBlock)successBlock errorBlock:(RSNetflixAPIRequestErrorBlock)errorBlock;
@end