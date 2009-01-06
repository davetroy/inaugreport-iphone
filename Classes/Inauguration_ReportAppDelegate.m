//
//  Inauguration_ReportAppDelegate.m
//  Inauguration Report
//
//  Created by David Troy on 1/6/09.
//  Copyright Popvox LLC 2009. All rights reserved.
//

#import "Inauguration_ReportAppDelegate.h"
#import "RootViewController.h"


@implementation Inauguration_ReportAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
