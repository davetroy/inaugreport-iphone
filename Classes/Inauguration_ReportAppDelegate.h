//
//  Inauguration_ReportAppDelegate.h
//  Inauguration Report
//
//  Created by David Troy on 1/6/09.
//  Copyright Popvox LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Inauguration_ReportAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

