//
//  TextReportView.m
//  Inauguration Report
//
//  Created by Sze Wong on 1/9/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import "TextReportView.h"
#import "Constants.h"
#import "DbHelper.h"
#import "BlogProxy.h"


@implementation TextReportView

@synthesize isNewReport;
@synthesize myPost;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	captionTextField.returnKeyType = UIReturnKeyDone;
	captionTextField.autocorrectionType = UITextAutocorrectionTypeYes;
	captionTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	storyTextView.delegate = self;
	
	toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height- kOFFSET_FOR_KEYBOARD-44, 320, 44)] retain];
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(doStoryDone:)];
	[toolBar setItems:[NSArray arrayWithObject:saveItem] animated:NO];
	[saveItem release];	
	[self.view addSubview:toolBar];
	toolBar.hidden = YES;
	
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction) doSubmit{
	//Save to database
	[[DbHelper sharedInstance] initializeDatabase];
	sqlite3 *db = [DbHelper sharedInstance].database;
	BOOL isNew;
	
	if (self.myPost==nil) isNew = YES; 
	else isNew = NO;
	
	if (self.myPost==nil &&
		([captionTextField.text length] > 0 || [storyTextView.text length] > 0)
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
			if (![self.myPost.description isEqualToString:storyTextView.text]) self.myPost.description = storyTextView.text;
			
			
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

- (void) doStoryDone:(id) sender{
	toolBar.hidden = YES;
	[storyTextView resignFirstResponder];
}


////////////////////////////////////////////
//
// TextViewDelegate
////////////////////////////////////////////
/*
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	NSLog(@"didBeginEditing");
}
*/

- (void)textViewDidChange:(UITextView *)textView{
	int length = [textView.text length];
	[textView scrollRangeToVisible:NSMakeRange(length, 0)];
}

/*
- (void)textViewDidChangeSelection:(UITextView *)textView{
	NSLog(@"didChangeSelection");
}
*/

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
	NSLog(@"shoudBeingEditing");
	toolBar.frame = CGRectMake(0, self.view.frame.size.height- kOFFSET_FOR_KEYBOARD-77, 320, 44);
	toolBar.hidden = NO;	
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
