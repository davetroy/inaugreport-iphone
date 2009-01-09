//
//  Inauguration_ReportAppDelegate.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/8/09.
//  Copyright Zerion Consulting 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Inauguration_ReportAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
