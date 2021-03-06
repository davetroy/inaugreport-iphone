//
//  PhotoReportView.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/9/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"


@interface PhotoReportView : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIImageView *photoImageView;
	IBOutlet UITextField *captionTextField;
	
	BOOL isShowing; //work around for multiple call to 
	BOOL isTakingPicture;
	BOOL shouldSavetoAlbum;
	
	Post *myPost;
	BOOL isNewReport;
}

@property (nonatomic, retain) Post *myPost;
@property (nonatomic, assign) BOOL isNewReport;
@property (nonatomic, retain, readonly) UIImageView *photoImageView;

- (IBAction) doSubmit;
- (IBAction) doCancel;
- (IBAction) doTakePicture;
- (IBAction) doTextDone;
- (void) reset;

@end
