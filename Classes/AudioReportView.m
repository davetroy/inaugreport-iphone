//
//  AudioReportView.m
//  Inauguration Report
//
//  Created by Sze Wong on 1/9/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import "AudioReportView.h"
#import "Constants.h"
#import "DbHelper.h"
#import "BlogProxy.h"


@implementation AudioReportView

@synthesize isNewReport;
@synthesize myPost;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	audioCell = [[[AudioView alloc] initWithFrame:CGRectMake(10, 100, 300, 100)] retain]; 
	[self.view addSubview:audioCell];
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
	NSString *tmpSoundPath = [audioCell.soundFileURL path];
	NSData *fileData = [NSData dataWithContentsOfFile:tmpSoundPath];
	
	
	if (self.myPost==nil && fileData) 
	{
		self.myPost = [[Post alloc] initWithPrimaryKey:-1 database:db]; //Use property for assignment to ensure proper memory management.
		[self.myPost insertIntoDatabase:db];
		isNew = YES;
	}
	
	//Prevent the Blog thread from starting a upload when it is being updated.
	@synchronized([BlogProxy sharedInstance]){ //Use the blogProxy as a common lock token
		if (self.myPost!=nil && self.myPost.uploadIndicator!=POSTUPLOADINDICATOR_DONE) //For now, don't save if already upload. TODO, edit post.
		{
			//NSString *filename = [NSString stringWithFormat:@"%@-%d.caf",post.deviceId,post.scheduleTime];
			NSArray *filePaths =	NSSearchPathForDirectoriesInDomains (
																		 
																		 NSDocumentDirectory, 
																		 NSUserDomainMask,
																		 YES
																		 ); 
			
			NSString *recordingDirectory = [filePaths objectAtIndex: 0];
			NSString *targetSoundFilePath = [NSString stringWithFormat: @"%@/%d.caf", recordingDirectory, self.myPost.primaryKey];
			[[NSFileManager defaultManager] removeItemAtPath:targetSoundFilePath error:NULL];
			
			NSError *copyError;
			[[NSFileManager defaultManager] copyItemAtPath:tmpSoundPath toPath:targetSoundFilePath error:&copyError];
			
			if (copyError){
				//What to do!
				NSLog(@"%@",copyError);
			}
			
			
			

			self.myPost.title = @"Audio Report";
			self.myPost.description = targetSoundFilePath;
			
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
