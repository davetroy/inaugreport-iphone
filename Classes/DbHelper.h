//
//  DbHelper.h
//  GotCatch
//
//  Created by Sze Wong on 9/27/08.
//  Copyright 2008 Zerion Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#define DBNAME @"inaugreportdb.sqlite";


@interface DbHelper : NSObject {
    // Opaque reference to the SQLite database.
    sqlite3 *database;
}

@property(nonatomic, readonly)  sqlite3   *database;

- (void)initializeDatabase;
+ (DbHelper*)sharedInstance;
@end
