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
@synthesize uploading;


- (void)main{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"In blog thread");	
	
	BlogProxy *myBlogProxy = [BlogProxy sharedInstance];
	
	while (true){
		
		NSLog(@"BLOG THREAD: Getting Post");
		NSLog(@"BLOG THREAD: Pause=%s",pause?"YES":"NO");
		NSLog(@"BLOG THREAD: Uploading=%s",uploading?"YES":"NO");
		if (!pause  && !uploading) {
		//Pick the first unuploaded Post object from the database 
		myPost = [[delegate getNextUploadPost] retain];

		NSLog(@"BLOG THREAD: Got Post [%@]",myPost);		
		if (myPost != nil) {

			[myPost load];
			[myPost loadImage];
			NSLog(@"BLOG THREAD: PK=%d",myPost.primaryKey);		
			NSLog(@"BLOG THREAD: Title=%@",myPost.title);	
					
			//Try uploading it
			NSLog(@"BLOG THREAD: Uploading");	
			
			uploading = YES;
			myBlogProxy.reporter.target = self;
			myBlogProxy.reporter.targetSelector = @selector(uploadCompleted);
			[myBlogProxy sendPostToServer:myPost];
		}
		}//Pause
		
		//Sleep for 10 seconds
		NSLog(@"BLOG THREAD: Going to sleep");
		[NSThread sleepForTimeInterval:10];
	}
	[pool release];
	
}

- (void) uploadCompleted{
	
	BOOL success = [BlogProxy sharedInstance].reporter.successful;

	if (success){ //Update the uploadstatus
		NSLog(@"Upload Successful.");
		myPost.uploadIndicator = POSTUPLOADINDICATOR_DONE;
	} else {
		NSLog(@"Upload Failed.");
		myPost.uploadIndicator = POSTUPLOADINDICATOR_WAITING; //RESET. will try again later
	}
	
	[delegate newUploadStatus:myPost];
	[myPost release];
	uploading = NO;	//So the thread will continue
}


@end
