//
//  BlogProxy.m
//  GotCatch
//
//  Created by Sze Wong on 9/23/08.
//  Copyright 2008 Zerion Consulting. All rights reserved.
//

#import "BlogProxy.h"
#import "Constants.h"

/***********************
 * A Proxy class for calling all Blog XML RPC functions.
 */

// This is a singleton class, see below
static BlogProxy *si = nil;

@implementation BlogProxy


+ (BlogProxy *)sharedInstance {
    @synchronized(self) {
        if (si == nil) {
            si = [[self alloc] init];
        }
    }
    return si;
}

- (id)sendPostToServer:(Post *)post{
	return nil;
}

@end
