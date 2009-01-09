//
//  RegistrationView.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/8/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RegistrationView : UITableViewController {
	
	UITextField  *firstNameTextField;
	UITextField  *lastNameTextField;
	UITextField  *emailTextField;
	UITextField  *zipTextField;
	UITextView   *agreementTextView;
	
	//DataField
	BOOL isAgree;
}

- (void) doSave: (id) sender;

@end
