#import "RegistrationView.h"
#import "DisplayCell.h"
#import "DisplayCell2.h"
#import "CellTextView.h"
#import "CellTextField.h"
#import "CellButton.h"
#import "CellPicker.h"
#import "CellSlider.h"
#import "SourceCell.h"
#import "Constants.h"
#import "Util.h"

@implementation RegistrationView

@synthesize tableView;

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
	UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[returnButton setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
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



- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
	firstNameTextField.text =  [defaults objectForKey:DEFAULTKEY_FIRSTNAME];
	lastNameTextField.text  =  [defaults objectForKey:DEFAULTKEY_LASTNAME];
	emailTextField.text =  [defaults objectForKey:DEFAULTKEY_EMAIL];
	zipTextField.text =  [defaults objectForKey:DEFAULTKEY_ZIP];
	isAgree =  [(NSNumber*)[defaults objectForKey:DEFAULTKEY_AGREE] boolValue];
	[self.tableView reloadData];
	
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor clearColor];
	firstNameTextField = [[self createTextField_Rounded] retain];
	lastNameTextField = [[self createTextField_Rounded] retain];
	emailTextField = [[self createTextField_Rounded] retain];
	emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
	emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	zipTextField = [[self createTextField_Rounded] retain];
	zipTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	agreementTextView = [[self createTextView] retain];
	agreementTextView.text = @"1. You affirm that you are the rightful owner of the content you upload through this application and that uploaded materials are not copyrighted or owned by another person or entity.\n2. All content uploaded using this application will be considered licensed under a Creative Commons Attribution 3.0 United States License. http://creativecommons.org/licenses/by/3.0/us/\n3. All content uploaded using this application will be accessible online by the general public and may be utilized in other media formats, including but not limited to broadcast.\n4. Your personal contact information will be used solely by NPR, CBS News, and American University to contact you for journalistic purposes as part of their coverage of the inauguration, and for no other purpose. The information will not be made available to third parties.";
}



////////////////////////////////////////////////////////////
// UITableViewDataSource Implementation
//
//
///////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 7; 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result;
	if (indexPath.section==5 && indexPath.row==0) result = kUITextViewCellRowHeight; //Agreement
	else if (indexPath.section==5 && indexPath.row==1) result = kUIRowHeight; //I Agree
	else if (indexPath.row==1) result = kUIRowLabelHeight; //All other row 1
	else result = kUIRowHeight;
	
	return result;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	int num = 0;
	switch (section) {
		case 0: //Heading
			num=0;
			break;
		case 1: //First Name
			num=2;
			break;
		case 2: //Last Name
			num=2;
			break;
		case 3: //Email
			num=2;
			break;
		case 4: //Zip
			num=2;
			break;
		case 5: //Agreement
			num=2;
			break;
		case 6: //Save
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
		case 1: //First Name
			cell = [self obtainTableTextFieldCellForRow:row];
			if (row==0) {
				((CellTextField*)cell).tableView = self.tableView;
				((CellTextField*)cell).section = 1;
				((CellTextField*)cell).row = 0;
			}
			break;
		case 2: //Last Name
			cell = [self obtainTableTextFieldCellForRow:row];
			if (row==0) {
				((CellTextField*)cell).tableView = self.tableView;
				((CellTextField*)cell).section = 2;
				((CellTextField*)cell).row = 0;
			}			
			break;
		case 3: //Email
			cell = [self obtainTableTextFieldCellForRow:row];
			if (row==0) {
				((CellTextField*)cell).tableView = self.tableView;
				((CellTextField*)cell).section = 3;
				((CellTextField*)cell).row = 0;
			}			
			break;
		case 4: //Zip
			cell = [self obtainTableTextFieldCellForRow:row];
			if (row==0) {
				((CellTextField*)cell).tableView = self.tableView;
				((CellTextField*)cell).section = 4;
				((CellTextField*)cell).row = 0;
			}			
			break;
		case 5: //Agreement
			if (row=0) cell = [self obtainTableTextViewCellForRow:row];
			else cell = [self obtainTableSwitchCellForRow:row];
			break;
		case 6: //Submit
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
		case 1: //First Name
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
		case 2: //Last Name
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
		case 3: //Email
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((CellTextField *)sourceCell).view = emailTextField;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)sourceCell).sourceLabel.text = @"Please enter your email address";
			}
			break;
		case 4: //Zip
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((CellTextField *)sourceCell).view = zipTextField;
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)sourceCell).sourceLabel.text = @"Please enter your home zip code or city.";
			}
			break;
		case 5: //Other Problems
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
		case 6: //Submit
			((CellButton *)sourceCell).view = [self createUIButton];
			sourceCell.backgroundColor = [UIColor clearColor];

			break;
		default:
			break;
	}
	
	
    return sourceCell;
}

/*
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
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section==0) return (kCommentHeaderHeight*2.0);
    else return kCommentHeaderHeight;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	NSString *fileName = nil;
	
	if (section==0) return titleView;
	
	switch (section) {
		case 1: //FirstName
			fileName=@"f_name.png";
			break;
		case 2: //Last Name
			fileName=@"l_name.png";
			break;
		case 3: //Email
			fileName =@"email.png";
			break;
		case 4: //Zip
			fileName=@"zip.png";
			break;
		case 5: //Agreement
			fileName=nil;
			break;
		case 6: //Submit
			fileName=nil;
			break;
		default:
			break;
	}
	if (fileName){
		UIImage *image = [UIImage imageNamed:fileName];
		UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
		imageView.contentMode = UIViewContentModeLeft;
		return imageView;
	} else return nil;
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
	if (indexPath.section==5 && indexPath.row==1 && isAgree)
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
	if (indexPath.section==5 && indexPath.row==1) return indexPath; 
	return nil;
}


- (void)tableView:(UITableView *)itableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    [itableView deselectRowAtIndexPath:[itableView indexPathForSelectedRow] animated:YES];
	NSInteger section = newIndexPath.section;
	
	if (section==5 && newIndexPath.row==1){
		//[itableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
		isAgree = !isAgree;
	}
		[self.tableView reloadData];
}



- (void)doSave:(id)sender
{
	NSLog(@"Submit was clicked");
	if (!isAgree) { 
		[Util handleMsg:@"Please accept the Terms." withTitle:@"Error"];
		return;
	}
	if (!([firstNameTextField.text length] >0 && [lastNameTextField.text length] >0)){
		[Util handleMsg:@"Please enter your first name and last name" withTitle:@"Error"];
		return;
	}

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
	[defaults setObject:firstNameTextField.text forKey:DEFAULTKEY_FIRSTNAME];
	[defaults setObject:lastNameTextField.text forKey:DEFAULTKEY_LASTNAME];
	[defaults setObject:emailTextField.text forKey:DEFAULTKEY_EMAIL];
	[defaults setObject:zipTextField.text forKey:DEFAULTKEY_ZIP];
	[defaults setObject:[NSNumber numberWithBool:isAgree] forKey:DEFAULTKEY_AGREE];
	
	[defaults synchronize];
	
	[self dismissModalViewControllerAnimated:YES];
		
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
