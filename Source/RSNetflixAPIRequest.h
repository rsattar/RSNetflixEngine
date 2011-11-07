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

// Actual class declaration

@interface RSNetflixAPIRequest : NSObject <RSURLLoaderDelegate> {
    RSURLLoader *urlLoader;
    RSNetflixAPIContext *apiContext;
    
    NSString *identifier;
    
    id<RSNetflixAPIRequestDelegate> delegate;
}

@property(assign) id<RSNetflixAPIRequestDelegate> delegate;
@property(readonly) NSString *identifier;

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext;
- (NSString *)callAPIMethod:(NSString *)methodName arguments:(NSDictionary *)arguments isSigned:(BOOL)isSigned;

@end