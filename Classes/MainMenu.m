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
#import "ReportListView.h"
#import "Constants.h"


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
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[self presentModalViewController:photoReportView animated:YES];
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




- (void)dealloc {
	[reportListView release];
	[creditView release];
	[registerView release];
	[photoReportView release];
	[textReportView release];
	[audioReportView release];
    [super dealloc];
}


@end
