//
//  MainMenu.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/8/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainMenu : UIViewController {
	IBOutlet UIView                  *reportSubmitView;
	IBOutlet UIActivityIndicatorView *reportSubmitViewSpinner;
	IBOutlet UILabel				 *reportSubmitViewLabel;
	
	UIViewController *photoReportView;
	UIViewController *audioReportView;
	UIViewController *textReportView;
	

}

- (IBAction) doAudioReport;
- (IBAction) doPhotoReport;
- (IBAction) doTextReport;

@end
