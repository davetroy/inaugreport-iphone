//
//  BlogProxy.h
//  GotCatch
//
//  Created by Sze Wong on 9/23/08.
//  Copyright 2008 Zerion Consulting. All rights reserved.
//
#import "Post.h"

#define kRSDErrorTag 901


@interface BlogProxy : NSObject {

}
- (id)sendPostToServer:(Post*)post;
+ (BlogProxy *)sharedInstance;

@end
