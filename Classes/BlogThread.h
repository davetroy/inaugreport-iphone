//
//  BlogThread.h
//  GotCatch
//
//  Created by Sze Wong on 10/1/08.
//  Copyright 2008 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

// This protocol is used to send message back to another view controller
@protocol BlogThreadDelegate <NSObject>
@required
-(Post *)getNextUploadPost;
-(void)newUploadStatus:(Post *)post;
-(void)newUploadError:(NSError *)err;
@end


@interface BlogThread : NSThread {
	id delegate;
	BOOL pause;
	BOOL uploading;
	Post *myPost;
}

@property (nonatomic,assign) id <BlogThreadDelegate> delegate;
@property (nonatomic,assign) BOOL pause;
@property (nonatomic,assign) BOOL uploading;

- (void) uploadCompleted;

@end
