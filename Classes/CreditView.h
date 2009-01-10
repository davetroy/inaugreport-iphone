//
//  CreditView.h
//  Inauguration Report
//
//  Created by Sze Wong on 1/9/09.
//  Copyright 2009 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreditView : UIViewController {
	UIViewController *mainMenu;
	UIViewController *registerView;
	
}

@property (nonatomic, retain) UIViewController *mainMenu;

- (IBAction) doBack;
- (IBAction) doRegistration;

@end
