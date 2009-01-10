//
//  Inauguration_ReportAppDelegate.m
//  Inauguration Report
//
//  Created by Sze Wong on 1/8/09.
//  Copyright Zerion Consulting 2009. All rights reserved.
//

#import "Inauguration_ReportAppDelegate.h"
#import "MainMenu.h"
#import "Reachability.h"


@implementation Inauguration_ReportAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	[[Reachability sharedReachability] setHostName:REACHABILITY_TEST_URL];
	
}


- (void)dealloc {
	[viewController release];
    [window release];
    [super dealloc];
}

@end

