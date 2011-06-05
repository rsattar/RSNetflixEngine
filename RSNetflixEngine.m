//
//  RSNetflixEngine.m
//  RSNetflixEngine
//
//  Created by Rizwan on 5/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSNetflixEngine.h"

@implementation RSNetflixEngine
- (void)dealloc
{
    [apiContext release];
    
    [activeURLConnections release];
    
    [super dealloc];
}

- (id)initWithAPIContext:(RSNetflixAPIContext *)inAPIContext
{
    if ((self = [super init])) {
        apiContext = [inAPIContext retain];
        
        activeURLConnections = [[NSMutableArray array] retain];
    }
    return self;
}

@end
