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
	//Text Report
	//Title : post.title
	//Body  : post.description
	//post.image == nil
	
	//Photo Report
	//Caption : post.title
	//Photo   : post.image
	//post.description == nil
	
	//Audio Report
	//Caption : @"Audio Report"
	//Sound file : [root path]/[post.primaryKey].caf
	//post.description = sound path. //For now.
	
	
	return nil;
}

@end
