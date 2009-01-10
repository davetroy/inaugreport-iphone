#import "ReportListView.h"
#import "Util.h"
#import "BlogProxy.h"
#import "DbHelper.h"
#import "Post.h"
#import "PostTableCell.h"

#define ROW_HEIGHT 80

@implementation ReportListView

@synthesize contentArray;

- (BOOL)handleError:(NSError *)err
{
	return [Util handleMsg:[err localizedDescription] withTitle:@"Error"];
}


-(int)getIndexForRow:(int)r{
	int c = [contentArray count];
	return c-1-r;
}
- (void)doCancelPost{
	[[self navigationController] popViewControllerAnimated:YES];	
}


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

// This table will always only have one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (contentArray== nil || [contentArray count]==0 ) {
		[self loadContent];
	}
	return [contentArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	static NSString *CellIdentifier = @"PostCell";
	
	PostTableCell *postTableCell = (PostTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (postTableCell == nil) {
		CGRect startingRect = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
		postTableCell = [[[PostTableCell alloc] initWithFrame:startingRect reuseIdentifier:CellIdentifier] autorelease];
	}
	
	int r = indexPath.row;
	int c = [self getIndexForRow:r];
	Post *myPost = nil;
	
	if (c>=0) {
		myPost = [contentArray objectAtIndex:c];
		NSLog(@"Row=%d, Key=%d",r, myPost.primaryKey);
		[myPost load];

		NSLog(@"Backed");
		[postTableCell setTitle:myPost.title];
		NSLog(@"Title=%@",myPost.title);
		[postTableCell setDescription:myPost.description];
		postTableCell.uploadIndicator = myPost.uploadIndicator;
		postTableCell.anchor = !myPost.manualLocaitonOverride; //Don't show anchor if it's manual.
		NSLog(@"TimeModified = %@", [myPost.timeModified description]);
		if (myPost.timeModified!=nil) [postTableCell setTimeModified:myPost.timeModified];
		NSLog(@"TimeCreated = %@", [myPost.timeCreated description]);
		if (myPost.timeCreated!=nil) [postTableCell setTimeCreated:myPost.timeCreated];
	
		[postTableCell setImage:myPost.thumbnail];
		NSLog(@"Loaded Post. Title=%@, Description=%@",myPost.title, myPost.description);
	}
	
	return postTableCell;
	
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];	

	int r = indexPath.row;
	int c = [self getIndexForRow:r];
	Post *myPost = nil;
	
	if (c>=0){
		myPost = [contentArray objectAtIndex:[self getIndexForRow:r]];
	
		//Don't go anywhere if it's uploading
		if (myPost.uploadIndicator == POSTUPLOADINDICATOR_UPLOADING) 
			return indexPath;
	
		NSLog(@"Row=%d, Key=%d",r, myPost.primaryKey);
		[myPost load];
	
		NSLog(@"Backed");
		blogThread.pause = YES; //Pause the thread to prevent slowing down blog editing.

		//TODO. show the correct view controller
		//[self.navigationController pushViewController:postViewController animated:YES];
	}

	return nil;

}

// The accessory type is the image displayed on the far right of each table cell. In order for the delegate method
// tableView:accessoryButtonClickedForRowWithIndexPath: to be called, you must return the "Detail Disclosure Button" type.
- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	int r = indexPath.row;
	Post *myPost = nil;
	int c = [self getIndexForRow:r];
	if (c>=0) myPost = [contentArray objectAtIndex:c];
	
	int type = UITableViewCellAccessoryDisclosureIndicator;
	
	//When ready to support changing report before upload, comment the following.
	type = UITableViewCellAccessoryNone;
	
	//Don't go anywhere if it's uploading
	if (myPost == nil || myPost.uploadIndicator == POSTUPLOADINDICATOR_UPLOADING) type = UITableViewCellAccessoryNone;
	//if (myPost.uploadIndicator == POSTUPLOADINDICATOR_DONE) type = UITableViewCellAccessoryNone;
	
    return type;
}

// Invoked when the user touches Edit.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    // Updates the appearance of the Edit|Done button as necessary.
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    // Disable the add button while editing.
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
     // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		int r = indexPath.row;
		int c = [self getIndexForRow:r];
		Post *p = nil;
		
		if (c>=0) p = [contentArray objectAtIndex:c];
		
		//Can't delete if it's being upload
		if (p!=nil && p.uploadIndicator!=POSTUPLOADINDICATOR_UPLOADING){
			[p deleteFromDatabase];
			
			//If the blog thread is getting a post, we need to wait till it's done.
			@synchronized([BlogProxy sharedInstance]){ //Use the blogProxy as a common lock token
				[contentArray removeObjectAtIndex:c];
			}
			
			
			// Animate the deletion from the table.
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
			 withRowAnimation:UITableViewRowAnimationFade];
		}
    }
}

- (void) startSpin{
	spinIndicator.hidden = NO;
	[spinIndicator startAnimating];
}

- (void) stopSpin{
	spinIndicator.hidden = YES;
	[spinIndicator stopAnimating];
}

////////////////////////////////
//
// BlogThreadDelegate
//
////////////////////////////////
- (Post *)getNextUploadPost{
	
	//Prevent the main thread from updating (In PostViewController) or deleting any Post while the Blog thread gets the next post for upload
	@synchronized([BlogProxy sharedInstance]){ //Use the blogProxy as a common lock token
		Post *myPost;
		for (myPost in contentArray){
			[myPost load];
			
			NSLog(@"GETNEXTUPADLOPOST TITLE=%@",myPost.title);
			if (myPost.uploadIndicator==POSTUPLOADINDICATOR_UPLOADING) return myPost;
			
			if (myPost.uploadIndicator==POSTUPLOADINDICATOR_WAITING){
				myPost.uploadIndicator = POSTUPLOADINDICATOR_UPLOADING;
				[myPost save];
				[self.tableView performSelector:@selector(reloadData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
				return myPost;
			}
		}
	}
	return nil;
}

-(void)newUploadStatus:(Post *)post{
	//Prevent the main thread from updating (In PostViewController) or deleting any Post while the Blog thread gets the next post for upload	
	@synchronized([BlogProxy sharedInstance]){ //Use the blogProxy as a common lock token
		[post save];
	}
	[self.tableView performSelector:@selector(reloadData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}

-(void)newUploadError:(NSError *)err{
	[self performSelector:@selector(handleError:) onThread:[NSThread mainThread] withObject:err waitUntilDone:NO];
}



- (void)loadView 
{ 
	self.title = @"Report Queue";

	[self loadContent];
	UITableView *tableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] 
													applicationFrame] 
											 style:UITableViewStylePlain] autorelease]; 
	tableView.autoresizingMask = 
	UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth; 
	tableView.delegate = self; 
	tableView.dataSource = self; 
	[tableView reloadData]; 
	self.tableView = tableView; 

	/*
	//Start the upload thread
	blogThread = [[[BlogThread alloc] init]retain];
	blogThread.delegate = self;
	blogThread.pause = YES;
	[blogThread start];	
	*/
} 


- (void)viewWillAppear:(BOOL)animated{
	[self loadContent];
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	//blogThread.pause = NO; //Let the thread do it's job only if we are in this screen.
	
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
	[serverActivity release];
}


@end
