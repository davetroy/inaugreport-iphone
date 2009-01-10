//
//  RegistrationView.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/8/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RegistrationView : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *tableView;
	IBOutlet UIView *titleView;
	
	UITextField  *firstNameTextField;
	UITextField  *lastNameTextField;
	UITextField  *emailTextField;
	UITextField  *zipTextField;
	UITextView   *agreementTextView;
	
	//DataField
	BOOL isAgree;
}

@property (nonatomic, retain) UITableView *tableView;

- (void) doSave: (id) sender;

@end
