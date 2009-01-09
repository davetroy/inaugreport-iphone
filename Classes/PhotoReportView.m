//
//  PhotoReportView.m
//  Inauguration Report
//
//  Created by Sze Wong on 1/9/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import "PhotoReportView.h"
#import "BlogProxy.h"
#import "DbHelper.h"
#import "Constants.h"
#import "Util.h"


@implementation PhotoReportView

@synthesize myPost;
@synthesize isNewReport;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	captionTextField.returnKeyType = UIReturnKeyDone;
	captionTextField.autocorrectionType = UITextAutocorrectionTypeYes;
	captionTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	isShowing = NO;
	isTakingPicture = NO;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	if (photoImageView.image==nil) [self doTakePicture];
}

- (void)takePicture {
	
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && !isTakingPicture)
	{
		UIImagePickerController *picker;
		picker = [[[UIImagePickerController alloc] init] autorelease];
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.delegate = self;
		
		[self presentModalViewController:picker animated:YES];
		isTakingPicture = YES;
	}
}

- (void)pickPicture
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] && !isTakingPicture)
	{
		UIImagePickerController *picker;
		picker = [[[UIImagePickerController alloc] init] autorelease];
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.delegate = self;
		
		[self presentModalViewController:picker animated:YES];
		isTakingPicture = YES;
	}
	
}


- (IBAction) doTakePicture {
	
	//If it has a camera, ask.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {	
		if (!isShowing) {
			UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self 
											    cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:nil 
											    otherButtonTitles:@"Take a picture with camera", @"Pick from photo library",nil];
	
			[aSheet showInView:self.view];
			isShowing = YES;
		}
	} else [self pickPicture];
}

- (IBAction) doSubmit {
	
	//Save to database
	[[DbHelper sharedInstance] initializeDatabase];
	sqlite3 *db = [DbHelper sharedInstance].database;
	BOOL isNew;
	
	if (self.myPost==nil) isNew = YES; 
	else isNew = NO;
	
	if (self.myPost==nil &&
		([captionTextField.text length] > 0 || photoImageView.image!=nil)
		) 
	{
		self.myPost = [[Post alloc] initWithPrimaryKey:-1 database:db]; //Use property for assignment to ensure proper memory management.
		[self.myPost insertIntoDatabase:db];
		isNew = YES;
	}
	
	//Prevent the Blog thread from starting a upload when it is being updated.
	@synchronized([BlogProxy sharedInstance]){ //Use the blogProxy as a common lock token
		if (self.myPost!=nil && self.myPost.uploadIndicator!=POSTUPLOADINDICATOR_DONE) //For now, don't save if already upload. TODO, edit post.
		{
			if (![self.myPost.title isEqualToString:captionTextField.text]) self.myPost.title = captionTextField.text;
			
			NSNumber *imageSize = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTKEY_IMGSIZE];
			int imagePixelSize; 
			switch ([imageSize intValue]) {
				case 0:
					imagePixelSize = 300;
					break;
				case 1:
					imagePixelSize = 600;
					break;
				case 2:
					imagePixelSize = photoImageView.image.size.width;
					break;
				default:
					break;
			}	
			if (self.myPost.image != photoImageView.image){ //The UIImage should point to the exact object if image did not change.
				self.myPost.image = [Util scaleAndRotateImage:photoImageView.image maxResolution:imagePixelSize]; //Set scale on this to make is slightly smaller and rotate correctly before saving to the database
				self.myPost.thumbnail = [Util scaleAndRotateImage:photoImageView.image maxResolution:80];
			}
			
			//Get current location
			/*
			self.myPost.lat = myLat;
			self.myPost.lon = myLon;
			self.myPost.alt = myAlt;
			self.myPost.v_accuracy = myVAccuracy;
			self.myPost.h_accuracy = myHAccuracy;
			*/
			
			[self.myPost save]; //Save won't do anything if the object is not dirty.
			[self.myPost saveImage]; //Same here.
			self.myPost = nil;
		}
	} //syn
	
	if (isNewReport) [self dismissModalViewControllerAnimated:YES]; 
	else {
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	
}

- (IBAction) doCancel{
	if (isNewReport) [self dismissModalViewControllerAnimated:YES]; 
	else {
		[self.navigationController popViewControllerAnimated:YES];
	}
	
}

- (IBAction) doTextDone{
 //Dummy	
}


///////////////////////////////////////////////
//
//ActionSheet Delegate Method
//
//////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSLog(@"Selected %d",buttonIndex);
	switch (buttonIndex) {
		case 0:
			[self takePicture];
			break;
		case 1:
			[self pickPicture];
			break;
		default:
			[self doCancel];
			break;
	}
	isShowing = NO;
}

///////////////////////////////////////////////
//
//ImagePicker Delegate Method
//
//////////////////////////////////////////////
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	photoImageView.image = image;
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];	
	isTakingPicture = NO;
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];	
	isTakingPicture = NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
