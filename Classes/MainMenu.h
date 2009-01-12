//
//  MainMenu.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/8/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"


@interface MainMenu : UIViewController {
	IBOutlet UIView                  *reportSubmitView;
	IBOutlet UIActivityIndicatorView *reportSubmitViewSpinner;
	IBOutlet UILabel				 *reportSubmitViewLabel;
	
	UIViewController *photoReportView;
	UIViewController *audioReportView;
	UIViewController *textReportView;
	UIViewController *registerView;
	UIViewController *creditView;
	UIViewController *reportListView;
	
	NSMutableArray *contentArray;
	
	Post *currentPost;
	int currentPostIndex;
	
	BOOL isForceFail; //For testing only.

}

- (IBAction) doAudioReport;
- (IBAction) doPhotoReport;
- (IBAction) doTextReport;
- (IBAction) doRegister;
- (IBAction) flipCredit;

- (void) loadContent;
- (void) uploadPost;
- (void) newUploadStatus:(Post *)post;
- (Post *) getNextUploadPost;
- (void) showStatus:(id)numInQueue;
- (void) hideStatus;

@end
