//
//  MainMenu.m
//  Inauguration Report
//
//  Created by Sze Wong on 1/8/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import "Inauguration_ReportAppDelegate.h"
#import "MainMenu.h"
#import "PhotoReportView.h"
#import "AudioReportView.h"
#import "TextReportView.h"
#import "RegistrationView.h"
#import "CreditView.h"
#import "Constants.h"
#import "DbHelper.h"
#import "BlogProxy.h"
#import "Util.h"
#import "Reachability.h"


@implementation MainMenu

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
- (BOOL)handleError:(NSError *)err
{
	return [Util handleError:err];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	reportSubmitView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)a{
	[super viewDidAppear:a];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
	NSString *firstName =  [defaults objectForKey:DEFAULTKEY_FIRSTNAME];
	NSString *lastName  =  [defaults objectForKey:DEFAULTKEY_LASTNAME];
	if (!([firstName length]>0 && [lastName length]>0)) [self doRegister];
	
	currentPostIndex = -1; //So upload starts from top
	[self loadContent]; //Load from the databae once per screen show.
	[self uploadPost];
}

- (void)viewDidDisappear:(BOOL)a{
	[super viewDidDisappear:a];
	[self hideStatus];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)loadContent{
	@synchronized([BlogProxy sharedInstance]){ //Use the blogProxy as a common lock token
		[contentArray release];
		contentArray = [[NSMutableArray alloc] init];
		
		[[DbHelper sharedInstance] initializeDatabase];
		sqlite3 *db = [DbHelper sharedInstance].database;
		const char *sql = "SELECT ID FROM POST";
		sqlite3_stmt *statement;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the book objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the books array.
				Post *p = [[Post alloc] initWithPrimaryKey:primaryKey database:db];
				[contentArray addObject:p];
				[p release];
			}
		}
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
	}
}


- (IBAction) doRegister{
	if (registerView==nil) registerView = [[[RegistrationView alloc] init] retain];
	[self presentModalViewController:registerView animated:YES];	
}  	

- (IBAction) doAudioReport{
	if (audioReportView==nil) audioReportView = [[[AudioReportView alloc] init] retain];
	((AudioReportView*)audioReportView).isNewReport = YES;
	[self presentModalViewController:audioReportView animated:YES];	
}

- (IBAction) doPhotoReport{
	if (photoReportView==nil) photoReportView = [[[PhotoReportView alloc] init] retain];
	((PhotoReportView*)photoReportView).isNewReport = YES;
	[((PhotoReportView*)photoReportView) reset];
	[self presentModalViewController:photoReportView animated:YES];
	//[((PhotoReportView*)photoReportView) doTakePicture];
	
}

- (IBAction) doTextReport{
	if (textReportView==nil) textReportView = [[[TextReportView alloc] init] retain];
	((TextReportView*)textReportView).isNewReport = YES;
	[self presentModalViewController:textReportView animated:YES];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (IBAction) flipCredit{
	if (creditView==nil) {
		creditView = [[[CreditView alloc] init] retain];
		((CreditView*)creditView).mainMenu = self;
	}
	
	
	UIWindow *window = ((Inauguration_ReportAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationTransition: ([self.view superview] ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight) forView:window cache:YES];
	
	if ([self.view superview]){
		[self.view removeFromSuperview];
		[window addSubview:creditView.view];
	} else {
		[creditView.view removeFromSuperview];
		[window addSubview:self.view];
	}
	
	[UIView commitAnimations];
    
}

//This selector is run in the background
- (void) showStatus:(id)numInQueue{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
	reportSubmitViewLabel.text = [NSString stringWithFormat:@"Uploading report (%d/%@ in queue)...",currentPostIndex+1,numInQueue];
	reportSubmitView.hidden = NO;
	[reportSubmitViewSpinner startAnimating];
	[pool release];
}
- (void) hideStatus{
	reportSubmitView.hidden = YES;
	[reportSubmitViewSpinner stopAnimating];
}



///////////////////////////////////
//
// Upload 
//
///////////////////////////////////
- (void)uploadPost{
	
	//Pick the first unuploaded Post object from the database 
	currentPost = [[self getNextUploadPost] retain];
	NetworkStatus status = [[Reachability sharedReachability] internetConnectionStatus];
	
	if (currentPost != nil && status!=NotReachable) {
		NSLog(@"Uploading Post [%@]",currentPost);		

		
		[currentPost load];
		[currentPost loadImage];
		NSLog(@"UPLOAD: PK=%d",currentPost.primaryKey);		
		NSLog(@"UPLOAD: Title=%@",currentPost.title);	
		
		//Try uploading it
		NSLog(@"UPLOAD: Uploading");	
		
		BlogProxy *myBlogProxy = [BlogProxy sharedInstance];
		myBlogProxy.reporter.target = self;
		myBlogProxy.reporter.targetSelector = @selector(uploadCompleted);
		[myBlogProxy sendPostToServer:currentPost];
		
		[self performSelectorInBackground:@selector(showStatus:) withObject:[NSNumber numberWithInt:[contentArray count]]];
		
	} else { //Upload is done. Or not reable. See if the queue is empty.
		[self loadContent]; //Reload from the database
		if ([contentArray count] > 0) {
			reportSubmitView.hidden = NO;
			reportSubmitViewLabel.text = [NSString stringWithFormat:@"%d report%@ in queue",[contentArray count], [contentArray count]>1?@"s":@""];
			[reportSubmitViewSpinner stopAnimating];
		}
		[UIApplication sharedApplication].applicationIconBadgeNumber =  [contentArray count];
		BOOL noteShown = ((Inauguration_ReportAppDelegate *)[[UIApplication sharedApplication] delegate]).unreachableNoteShown;
		if (status==NotReachable && !noteShown) { 
			((Inauguration_ReportAppDelegate *)[[UIApplication sharedApplication] delegate]).unreachableNoteShown = YES;
			[Util handleMsg:@"Cannot connect to the internet. You can continue to create reports and they will be saved locally. Restart the application when internet connection is available to upload reports." withTitle:@"Connection Error"];
		}
		
		
	}
}

- (void) uploadCompleted{
	
	BOOL success = [BlogProxy sharedInstance].reporter.successful;
	
	if (success){ //Update the uploadstatus
		NSLog(@"Upload Successful.");
		currentPost.uploadIndicator = POSTUPLOADINDICATOR_DONE;
	} else {
		NSLog(@"Upload Failed.");
		currentPost.uploadIndicator = POSTUPLOADINDICATOR_WAITING; //RESET. will try again later
		currentPost.v_accuracy +=1.0; //using this as fail count.
		NSLog(@"Fail Count = %f",currentPost.v_accuracy);
	}
	
	[self newUploadStatus:currentPost];
	[currentPost release];
}


-(Post *)getNextUploadPost{
	currentPostIndex++;
	
	if ([contentArray count]==0 || currentPostIndex < 0 || currentPostIndex >= [contentArray count]) {
		return nil;
	}
	
	Post *returnPost = nil;

	//Prevent the main thread from updating or deleting any Post while the Blog thread gets the next post for upload
	@synchronized([BlogProxy sharedInstance]){ //Use the blogProxy as a common lock token
		Post *myPost=nil;
		while (returnPost==nil && currentPostIndex < [contentArray count]){
			myPost = (Post*)[contentArray objectAtIndex:currentPostIndex];
			if (myPost==nil) return nil; //Should not happen, but just in case.
			
			[myPost load];
			
			NSLog(@"GETNEXTUPADLOPOST INDEX=%d TITLE=%@",currentPostIndex, myPost.title);
			if (myPost.uploadIndicator==POSTUPLOADINDICATOR_UPLOADING) {
				returnPost = myPost;
			} else if (myPost.uploadIndicator==POSTUPLOADINDICATOR_WAITING){
				myPost.uploadIndicator = POSTUPLOADINDICATOR_UPLOADING;
				[myPost save];
				returnPost = myPost;
			} else { //This should not happen in this project.
				NSLog(@"ERROR: Post[%d] already uploaded but still in the database. Skipping",myPost.primaryKey);
				currentPostIndex++;
			}
		}
	}
	
	return returnPost;
	
}

-(void)newUploadStatus:(Post *)post{
	//Prevent the main thread from updating (In PostViewController) or deleting any Post while the Blog thread gets the next post for upload	
	@synchronized([BlogProxy sharedInstance]){ //Use the blogProxy as a common lock token
		[post save];
		[post load];
		if (post.uploadIndicator == POSTUPLOADINDICATOR_DONE){
			//Delete audio file if any
			if ([post.title isEqualToString:@"Audio Report"]){
				NSString *soundfile = post.description;
				NSLog(@"Deleting sound file [%@]",soundfile);
				[[NSFileManager defaultManager] removeItemAtPath:soundfile error:nil];
			}
			NSLog(@"Deleting post[%d:%@]",post.primaryKey,post.title);
			[post deleteFromDatabase];
		} 			
	}
	[self hideStatus];
	
	//Now try again
	[self uploadPost];
}




- (void)dealloc {
	[contentArray release];
	[reportListView release];
	[creditView release];
	[registerView release];
	[photoReportView release];
	[textReportView release];
	[audioReportView release];
    [super dealloc];
}


@end
