//
//  BlogThread.m
//  GotCatch
//
//  Created by Sze Wong on 10/1/08.
//  Copyright 2008 Zerion Consulting. All rights reserved.
//

#import "BlogThread.h"
#import "BlogProxy.h"
#import "DbHelper.h"
#import "Post.h"
#import "Constants.h"


@implementation BlogThread

@synthesize delegate;
@synthesize pause;


- (void)main{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"In blog thread");	
	
	BlogProxy *myBlogProxy = [BlogProxy sharedInstance];
	
	while (true){
		
		
		NSLog(@"BLOG THREAD: Getting Post");
		NSLog(@"BLOG THREAD: Pause=%s",pause?"YES":"NO");
		if (!pause) {
		//Pick the first unuploaded Post object from the database 
		Post *myPost = [[delegate getNextUploadPost] retain];

		NSLog(@"BLOG THREAD: Got Post [%@]",myPost);		
		if (myPost != nil) {

			[myPost load];
			[myPost loadImage];
			NSLog(@"BLOG THREAD: PK=%d",myPost.primaryKey);		
			NSLog(@"BLOG THREAD: Title=%@",myPost.title);	
					
			//Try uploading it
			NSLog(@"BLOG THREAD: Uploading");	
			NSString *postid = nil;
			
			// Step 1. Send Image (inside the send to Blog call
			// Step 2. Send the blog
			
			id response = [myBlogProxy sendPostToServer:myPost];
			if ([response isKindOfClass:[NSError class]] ){
				//Tell the delegate we have an error
				[delegate newUploadError:response];
			} else {
				postid = (NSString *)response;	
			}
			NSLog(@"BLOG THREAD: PostID=%@",postid);
			NSLog(@"BLOG THREAD: Upload done");
			if (postid!=nil){ //Update the uploadstatus
				myPost.postId = postid;
				myPost.uploadIndicator = POSTUPLOADINDICATOR_DONE;
				
				
			} else myPost.uploadIndicator = POSTUPLOADINDICATOR_WAITING; //RESET
			
			[delegate newUploadStatus:myPost];
			
		}
		//Closing database
		[myPost release];
		}//Pause
		
		//Sleep for 10 seconds
		NSLog(@"BLOG THREAD: Going to sleep");
		[NSThread sleepForTimeInterval:10];
	}
	[pool release];
	
}


@end
