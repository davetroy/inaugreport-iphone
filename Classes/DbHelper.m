//
//  DbHelper.m
//  GotCatch
//
//  Created by Sze Wong on 9/27/08.
//  Copyright 2008 Zerion Consulting. All rights reserved.
//

#import "DbHelper.h"
#import "BlogProxy.h"


// This is a singleton class, see below
static DbHelper *dbh = nil;

@implementation DbHelper

@synthesize database;

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbName = DBNAME;
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (void)createEditableCopyOfDatabase{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbName = DBNAME;
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];
	
	[fileManager removeItemAtPath:writableDBPath error:nil];

    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}


// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {

	if (database!=nil) return;
	
	[self createEditableCopyOfDatabaseIfNeeded];
	//[self createEditableCopyOfDatabase];

    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dbName = DBNAME;
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbName];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
	
	//NOW, try to send the database file to the server
	//Doesn't work yet.
	//[[BlogProxy sharedInstance] sendFileToServer:path asName:dbName];
}

+ (DbHelper *)sharedInstance {
    @synchronized(self) {
        if (dbh == nil) {
            dbh = [[self alloc] init];
        }
    }
    return dbh;
}

- (void)dealloc{
	[super dealloc];
	// Close the database.
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
	database = nil;
}	

@end
