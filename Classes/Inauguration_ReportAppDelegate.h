//
//  Inauguration_ReportAppDelegate.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/8/09.
//  Copyright Zerion Consulting 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainMenu;

@interface Inauguration_ReportAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	MainMenu   *viewController;
	
	BOOL unreachableNoteShown;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainMenu *viewController;
@property (nonatomic, assign) BOOL unreachableNoteShown;

@end
