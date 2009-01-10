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

@synthesize reporter;


+ (BlogProxy *)sharedInstance {
    @synchronized(self) {
        if (si == nil) {
            si = [[self alloc] init];
        }
    }
    return si;
}

-(id)init {
	if (self = [super init]) {
		reporter = [[[Reporter alloc] init] retain];
	}
	return self;
}

- (NSString *)saveImageToTmp:(UIImage*)image{
	if (image==nil) return nil;
	NSArray *filePaths =	NSSearchPathForDirectoriesInDomains (
																 
																 NSDocumentDirectory, 
																 NSUserDomainMask,
																 YES
																 ); 
	
	NSString *directory = [filePaths objectAtIndex: 0];
	NSString *fileString = [NSString stringWithFormat: @"%@/Image.jpg", directory];
	
	//Delete existing file
	[[NSFileManager defaultManager] removeItemAtPath:fileString error:NULL];
	
	NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
	BOOL success = [imageData writeToFile:fileString atomically:YES];
	if (success) return fileString;
	else return nil;
}



- (id)sendPostToServer:(Post *)post{
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		
	if ([post.title isEqualToString:@"Audio Report"]){
		//Audio Report
		//Caption : @"Audio Report"
		//Sound file : [root path]/[post.primaryKey].caf
		//post.description = sound path.
		if (post.description) [params setValue:post.description forKey:@"soundfile"];
	} else if (post.image!=nil){
		//Photo Report
		//Caption : post.title
		//Photo   : post.image
		//post.description == nil
		if (post.title) [params setValue:post.title forKey:@"report[title]"];
		NSString *imagefile = [self saveImageToTmp:post.image];
		if (imagefile) [params setValue:imagefile forKey:@"imagefile"];
	} else {
		//Text Report
    	//Title : post.title
    	//Body  : post.description
    	//post.image == nil
		if (post.title) [params setValue:post.title forKey:@"report[title]"];
		if (post.description) [params setValue:post.description forKey:@"report[body]"];
	}

	[reporter postReportWithParams:params];
	
	return @"1"; //Returning a string means success. nil if fail
}

- (void)dealloc {
   [reporter release];
   [super dealloc];
}

@end
