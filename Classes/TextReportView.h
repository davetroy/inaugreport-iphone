//
//  TextReportView.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/9/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"


@interface TextReportView : UIViewController <UITextViewDelegate>{
	IBOutlet UITextField *captionTextField;
	IBOutlet UITextView  *storyTextView;
	UIToolbar    *toolBar;
	BOOL isNewReport;
	Post *myPost;
	
}

@property (nonatomic, retain) Post *myPost;
@property (nonatomic, assign) BOOL isNewReport;

- (IBAction) doSubmit;
- (IBAction) doCancel;
- (IBAction) doTextDone;
- (void) doStoryDone:(id)sender;



@end
