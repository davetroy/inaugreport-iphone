//
//  AudioReportView.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/9/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "AudioView.h"


@interface AudioReportView : UIViewController {
	IBOutlet UIActivityIndicatorView *spinner;
	AudioView *audioCell;
	BOOL isNewReport;
	Post *myPost;
	
}

@property (nonatomic, retain) Post *myPost;
@property (nonatomic, assign) BOOL isNewReport;

- (IBAction) doSubmit;
- (IBAction) doCancel;

@end
