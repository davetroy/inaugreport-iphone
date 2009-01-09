#import "RegistrationView.h"
#import "DisplayCell.h"
#import "DisplayCell2.h"
#import "CellTextView.h"
#import "CellTextField.h"
#import "CellButton.h"
#import "CellPicker.h"
#import "CellSlider.h"
#import "CellAudio.h"
#import "SourceCell.h"
#import "Constants.h"

@implementation RegistrationView

#pragma mark
#pragma mark UITextField - rounded
#pragma mark
- (UITextField *)createTextField_Rounded
{
	CGRect frame = CGRectMake(0.0, 0.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *returnTextField = [[UITextField alloc] initWithFrame:frame];
    
	returnTextField.borderStyle = UITextBorderStyleRoundedRect;
    returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [UIFont systemFontOfSize:17.0];
    returnTextField.placeholder = @"";
    returnTextField.backgroundColor = [UIColor whiteColor];
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	returnTextField.keyboardType = UIKeyboardTypeDefault;
	returnTextField.returnKeyType = UIReturnKeyDone;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	return returnTextField;
}

- (UITextView *)createTextView
{
	CGRect frame = CGRectMake(0.0, 0.0, 280.0, 130.0);
	
	UITextView *textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont fontWithName:kFontName size:kTextViewFontSize];
    //textView.delegate = self; This textview is not going to be editable.
	textView.editable = NO;
    textView.backgroundColor = [UIColor whiteColor];
	
	//textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	return textView;
}

#pragma mark
#pragma mark UITextField - rounded
#pragma mark
- (UIButton *)createUIButton
{
	UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[returnButton setTitle:@"Save" forState:UIControlStateNormal];
	[returnButton addTarget:self action:@selector(doSave:) forControlEvents:UIControlEventTouchUpInside];
	
	//	UIImage *buttonBackground = [UIImage imageNamed:@"whiteButton.png"];
	//	UIImage *newImage = [buttonBackground stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	//	[returnButton setBackgroundImage:newImage forState:UIControlStateNormal];
	//	
	//	buttonBackground = [UIImage imageNamed:@"blueButton.png"];
	//	newImage = [buttonBackground stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	//	[returnButton setBackgroundImage:newImage forState:UIControlStateSelected];
	
	
	return returnButton;
}

- (void)awakeFromNib {
	[self initWithStyle:UITableViewStyleGrouped];
}


- (void)viewWillAppear:(BOOL)animated{
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	firstNameTextField = [[self createTextField_Rounded] retain];
	lastNameTextField = [[self createTextField_Rounded] retain];
	emailTextField = [[self createTextField_Rounded] retain];
	emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
	zipTextField = [[self createTextField_Rounded] retain];
	zipTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	agreementTextView = [[self createTextView] retain];
	agreementTextView.text = @"I, the undersigned responsible party (owner, tenant or agent for the property owner), hereby authorize the City Manager of the City of San Diego or the designated contractors or citizen volunteers acting under the direction of the City Manager to enter upon my property and remove graffiti pursuant to San Diego Municipal Code Sections 54.0401 through 54.0412. I understand and agree that the methods of removal of graffiti implemented may include but are not limited to chemical solvents, steam-cleaning, hydroblasting and sandblasting. I further understand and agree that such graffiti may be painted over by paint that will match or reasonably match the primary background color. Finally, I agree that in connection with this graffiti removal, I hereby release the City of San Diego, the City Manager and all contract agents and volunteers from all liability for any damage or injuries which I or my property may suffer as a result of entry onto property and/or graffiti removal. This authorization shall remain valid until revoked in writing by the undersigned. ";
}



////////////////////////////////////////////////////////////
// UITableViewDataSource Implementation
//
//
///////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 6; 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result;
	if (indexPath.section==4 && indexPath.row==0) result = kUITextViewCellRowHeight; //Agreement
	else if (indexPath.section==4 && indexPath.row==1) result = kUIRowHeight; //I Agree
	else if (indexPath.row==1) result = kUIRowLabelHeight; //All other row 1
	else result = kUIRowHeight;
	
	return result;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	int num = 0;
	switch (section) {
		case 0: //First Name
			num=2;
			break;
		case 1: //Last Name
			num=2;
			break;
		case 2: //Email
			num=2;
			break;
		case 3: //Zip
			num=2;
			break;
		case 4: //Agreement
			num=2;
			break;
		case 5: //Save
			num=1;
			break;
		default:
			break;
	}
	return num;
}



- (UITableViewCell *)obtainTableTextFieldCellForRow:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	if (row == 0)
		cell = [self.tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
	else if (row == 1)
		cell = [self.tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	
	if (cell == nil)
	{
		if (row == 0)
			cell = [[[CellTextField alloc] initWithFrame:CGRectZero reuseIdentifier:kCellTextField_ID] autorelease];
		else if (row == 1)
			cell = [[[SourceCell alloc] initWithFrame:CGRectZero reuseIdentifier:kSourceCell_ID] autorelease];
	}
	
	return cell;
}

- (UITableViewCell *)obtainTableTextViewCellForRow:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	if (row == 0)
		cell = [self.tableView dequeueReusableCellWithIdentifier:kCellTextView_ID];
	else if (row == 1)
		cell = [self.tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	
	if (cell == nil)
	{
		if (row == 0)
			cell = [[[CellTextView alloc] initWithFrame:CGRectZero reuseIdentifier:kCellTextView_ID] autorelease];
		else if (row == 1)
			cell = [[[SourceCell alloc] initWithFrame:CGRectZero reuseIdentifier:kSourceCell_ID] autorelease];
	}
	
	return cell;
}

- (UITableViewCell *)obtainTableSwitchCellForRow:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	cell = [self.tableView dequeueReusableCellWithIdentifier:kDisplayCell2_ID];
	
	if (cell == nil)
	{
		cell = [[[DisplayCell2 alloc] initWithFrame:CGRectZero reuseIdentifier:kDisplayCell2_ID] autorelease];
	}
	
	return cell;
}

- (UITableViewCell *)obtainTableDisplayCellForRow:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	if (row == 0)
		cell = [self.tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
	else if (row == 1)
		cell = [self.tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	
	if (cell == nil)
	{
		if (row == 0)
			cell = [[[DisplayCell alloc] initWithFrame:CGRectZero reuseIdentifier:kDisplayCell_ID] autorelease];
		else if (row == 1)
			cell = [[[SourceCell alloc] initWithFrame:CGRectZero reuseIdentifier:kSourceCell_ID] autorelease];
	}
	return cell;
}

- (UITableViewCell *)obtainTableButtonCellForRow:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	cell = [self.tableView dequeueReusableCellWithIdentifier:kCellButton_ID];
	
	if (cell == nil)
	{
		cell = [[[CellButton alloc] initWithFrame:CGRectZero reuseIdentifier:kCellButton_ID] autorelease];
	}
	
	return cell;
}





- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row inSection:(NSInteger)section
{
	UITableViewCell *cell = nil;
	switch (section) {
		case 0: //First Name
			cell = [self obtainTableTextFieldCellForRow:row];
			if (row==0) {
				((CellTextField*)cell).tableView = self.tableView;
				((CellTextField*)cell).section = 0;
				((CellTextField*)cell).row = 0;
			}
			break;
		case 1: //Last Name
			cell = [self obtainTableTextFieldCellForRow:row];
			if (row==0) {
				((CellTextField*)cell).tableView = self.tableView;
				((CellTextField*)cell).section = 1;
				((CellTextField*)cell).row = 0;
			}			
			break;
		case 2: //Email
			cell = [self obtainTableTextFieldCellForRow:row];
			if (row==0) {
				((CellTextField*)cell).tableView = self.tableView;
				((CellTextField*)cell).section = 1;
				((CellTextField*)cell).row = 0;
			}			
			break;
		case 3: //Zip
			cell = [self obtainTableTextFieldCellForRow:row];
			if (row==0) {
				((CellTextField*)cell).tableView = self.tableView;
				((CellTextField*)cell).section = 1;
				((CellTextField*)cell).row = 0;
			}			
			break;
		case 4: //Agreement
			if (row=0) cell = [self obtainTableTextViewCellForRow:row];
			else cell = [self obtainTableSwitchCellForRow:row];
			break;
		case 5: //Submit
			cell = [self obtainTableButtonCellForRow:row];
			break;
		default:
			break;
	}
	
	
	return cell;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UITableViewCell *sourceCell = [self obtainTableCellForRow:row inSection:section];
	
	switch (section) {
		case 0: //First Name
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((CellTextField *)sourceCell).view = firstNameTextField;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)sourceCell).sourceLabel.text = @"Please enter your first name.";
			}
			break;
		case 1: //Last Name
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((CellTextField *)sourceCell).view = lastNameTextField;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)sourceCell).sourceLabel.text = @"Please enter your last name.";
			}
			break;
		case 2: //Email
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((CellTextField *)sourceCell).view = emailTextField;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)sourceCell).sourceLabel.text = @"Please enter your email address.";
			}
			break;
		case 3: //Zip
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((CellTextField *)sourceCell).view = zipTextField;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)sourceCell).sourceLabel.text = @"Please enter your zip code.";
			}
			break;
		case 4: //Other Problems
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((CellTextView *)sourceCell).view = agreementTextView;
			}
			else
			{
				((DisplayCell *)sourceCell).nameLabel.text = @"I Agree";
			}
			break;
		case 5: //Submit
			((CellButton *)sourceCell).view = [self createUIButton];
			break;
		default:
			break;
	}
	
	
    return sourceCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title=nil;
	
	switch (section) {
		case 0: //First Name
			title = @"First Name";
			break;
		case 1: //Last Name
			title = @"Last Name";
			break;
		case 2: //Email
			title = @"Email";
			break;
		case 3: //Zip
			title=@"Zip Code";
			break;
		case 4: //Agreement
			title=nil;
			break;
		case 7: //Submit
			title=nil;
			break;
		default:
			break;
	}
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 4.0;
}

/*
 - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
 UIView *myEmptyView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,10,10)] autorelease];
 return myEmptyView;
 }
 */

- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section==4 && indexPath.row==1 && isAgree)
		return UITableViewCellAccessoryCheckmark;
	else 
		return UITableViewCellAccessoryNone;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	return NO;	
}

/*
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
 return YES;	
 }
 */

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// only allow selection of a couple of the rows
	if (indexPath.section==4 && indexPath.row==1) return indexPath; 
	return nil;
}


- (void)tableView:(UITableView *)itableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    [itableView deselectRowAtIndexPath:[itableView indexPathForSelectedRow] animated:YES];
	NSInteger section = newIndexPath.section;
	
	if (section==4 && newIndexPath.row==1){
		//[itableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
		isAgree = !isAgree;
	}
		[self.tableView reloadData];
}



- (void)doSave:(id)sender
{
	NSLog(@"Submit was clicked");
	/*
	NSString *name = nameTextField.text;
	NSString *pollingPlace = pollingPlaceTextField.text;
	NSString *rating  = [NSString stringWithFormat:@"%.0f", ratingSlider.value];
	NSString *comment = commentTextView.text;
	NSString *soundfile = [messageAudioCell.soundFileURL path];
	
	NSString *tags = [[NSMutableString alloc] init];
	if (machine) tags = [tags stringByAppendingString:@"#machine "];
	if (registration) tags = [tags stringByAppendingString:@"#registration "];
	if (challenges) tags = [tags stringByAppendingString:@"#challenges "];
	if (hava) tags = [tags stringByAppendingString:@"#hava "];
	if (ballots) tags = [tags stringByAppendingString:@"#ballots"];
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	if (name) [params setValue:name forKey:@"reporter[name]"];
	if (pollingPlace) [params setValue:pollingPlace forKey:@"polling_place[name]"];
	if (waitingTime) [params setValue:waitingTime forKey:@"report[wait_time]"];
	if (rating) [params setValue:rating forKey:@"report[rating]"];
	if (comment) [params setValue:comment forKey:@"report[text]"];
	if (tags) [params setValue:tags forKey:@"report[tag_string]"];
	if (messageAudioCell.didRecording && soundfile) [params setValue:soundfile forKey:@"soundfile"];
	
	[self dismissModalViewControllerAnimated:YES];
	[(Vote_ReportViewController *)self.parentViewController sendReportWith:params];
	 */
}


- (void)dealloc {
	[firstNameTextField release];
	[lastNameTextField release];
	[emailTextField release];
	[zipTextField release];
	[agreementTextView release];
    [super dealloc];
}

@end
