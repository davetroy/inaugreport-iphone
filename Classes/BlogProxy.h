//
//  BlogProxy.h
//  GotCatch
//
//  Created by Sze Wong on 9/23/08.
//  Copyright 2008 Zerion Consulting. All rights reserved.
//
#import "Post.h"
#import "Reporter.h"

#define kRSDErrorTag 901

@interface BlogProxy : NSObject {
	Reporter *reporter;

}

@property (nonatomic, readonly) Reporter *reporter;

- (id)sendPostToServer:(Post*)post;
+ (BlogProxy *)sharedInstance;

@end
