//
//  RSNetflixEngine.h
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSNetflixAPIContext.h"
#import "RSNetflixAPIRequest.h"

@interface RSNetflixEngine : NSObject {
    
    RSNetflixAPIContext *apiContext;
    
    NSMutableArray *activeURLConnections;
}

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext;

@end
