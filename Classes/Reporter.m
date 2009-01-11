//
//  Reporter.m
//  Vote Report
//
//  Created by David Troy on 10/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Reporter.h"
#import "HTTPManager.h"
#import "Constants.h"


@implementation Reporter
@synthesize location;
@synthesize target;
@synthesize targetSelector;
@synthesize successful;

-(id)init {
	if (self = [super init]) {
		location = nil;
		[self locate];
	}
	return self;
}

// locate the user using CoreLocation
-(void)locate {
	if (nil == locationManager)
		locationManager = [[CLLocationManager alloc] init];
	
    [locationManager stopUpdatingLocation];
    locationManager.delegate = self;
	locationManager.distanceFilter = 0; //kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
	// TESTING ONLY [self locationManager:locationManager didFailWithError:[NSError errorWithDomain:@"INAUGREPORT" code:kCLErrorDenied userInfo:nil]];
}

// deal with any errors - fail if we are not allowed to use location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Ignoring location error:%@", error);
	/*
	NSString *errorMsg;
	if (error.code ==  kCLErrorDenied) {
		errorMsg = @"Inauguration Report requires access to your location to work properly! Please call our automated phone-based system instead!";
	} else {
		errorMsg = @"Inauguration Report is unable to determine your location! Be sure you are not in airplane mode and have Wifi enabled, or please call our automated phone-based system!";
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Inauguration Report" message:errorMsg delegate:[[UIApplication sharedApplication] delegate]  cancelButtonTitle:@"Call Now" otherButtonTitles:@"Continue",nil];
	[alert show];
	*/
}	


// Delegate method from the CLLocationManagerDelegate protocol.
// Update a user's location and timezone at the server
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"location timestamp: %@ (%f seconds ago)", [newLocation.timestamp description], [newLocation.timestamp timeIntervalSinceNow]);
	if ([newLocation.timestamp timeIntervalSinceNow] > -5.0) {
		[locationManager stopUpdatingLocation];
		self.location = newLocation;
	}
}

// Setter for the user's location; initiate a HTTP request to get the name of this place
// when the user's location is set
-(void)setLocation:(CLLocation *)newLocation {
	location = newLocation;
	[location retain];
}


-(void)postReportWithParams:(NSMutableDictionary *)params {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
	NSString *firstName =  [defaults objectForKey:DEFAULTKEY_FIRSTNAME];
	NSString *lastName  =  [defaults objectForKey:DEFAULTKEY_LASTNAME];
	NSString *email     =  [defaults objectForKey:DEFAULTKEY_EMAIL];
	NSString *zipCode   =  [defaults objectForKey:DEFAULTKEY_ZIP];
	NSString *udid      =  [[UIDevice currentDevice] uniqueIdentifier];
	NSString *gpsStr    =  [NSString stringWithFormat:@"%.3f,%.3f:%.0f",
							location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy ];
	

	[params addEntriesFromDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
		 udid,      @"reporter[uniqueid]",
		 firstName, @"reporter[firstname]",
		 lastName,  @"reporter[lastname]",
		 email,     @"reporter[email]",
		 zipCode,   @"reporter[zipcode]",
		 nil]
	];
	if (location.horizontalAccuracy > 0) {
		NSLog(@"Posting with GPS info: [%@]",gpsStr);
		[params setValue:gpsStr forKey:@"report[latlon]"];
	} else {
		NSLog(@"Not posting GPS info: [%@]",gpsStr);	
	}
	
	HTTPManager *httpRequest = [[HTTPManager alloc] init];
	httpRequest.target = self;
	httpRequest.targetSelector = @selector(reportComplete:);
	NSString *soundfile = [params valueForKey:@"soundfile"];
	NSString *imagefile = [params valueForKey:@"imagefile"];
	if (soundfile)
		[httpRequest uploadFile:soundfile toUrl:REPORTS_URL withParameters:params];
	else if (imagefile)
		[httpRequest uploadFile:imagefile toUrl:REPORTS_URL withParameters:params];
	else
		[httpRequest performRequestWithMethod:@"POST" toUrl:REPORTS_URL withParameters:params];
}	

-(void)reportComplete:(HTTPManager *)manager
{
	successful = manager.successful;

	// Call our target's completion method
	if (target && [target respondsToSelector:targetSelector])
		[target performSelector:targetSelector withObject:self];
}

@end
