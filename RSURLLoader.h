//
//  RSURLLoader.h
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 Rizwan Sattar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSURLLoaderDelegate;
/**
 * This class encapsulates an NSURLConnection and manages its lifetime, collecting response data
 * and firing appropriate delegate callbacks
 */
@interface RSURLLoader : NSObject {
    
    NSURLRequest *urlRequest;
    
    NSURLConnection *connection;
    NSMutableData *receivedData;
    NSInteger statusCode;

    id <RSURLLoaderDelegate> delegate;
    NSObject *contextObj;
}

- (id)initWithURL:(NSString *)inURL delegate:(id)inDelegate;
- (void)start;

- (void)setContext:(NSObject *)context;
- (NSObject *)context;

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4
@property (nonatomic, copy) NSObject *context;
#endif

@end

@protocol RSURLLoaderDelegate <NSObject>
@optional
- (void)loader:(RSURLLoader *)loader didFinishWithStatusCode:(NSInteger)statusCode data:(NSData *)data;
- (void)loader:(RSURLLoader *)loader didFailWithError:(NSError*)error;
@end