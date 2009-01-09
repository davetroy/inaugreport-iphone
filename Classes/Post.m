#import "Post.h"
#import "Util.h"

// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *load_statement = nil;
static sqlite3_stmt *save_statement = nil;
static sqlite3_stmt *get_uploadrow_statement = nil;
static sqlite3_stmt *set_uploadrow_statement = nil;
static sqlite3_stmt *get_uploadingrow_statement = nil;


static sqlite3_stmt *insert_blob_statement = nil;
static sqlite3_stmt *delete_blob_statement = nil;
static sqlite3_stmt *load_blob_statement = nil;
static sqlite3_stmt *save_blob_statement = nil;


@implementation Post

@synthesize manualLocaitonOverride;

/*
 * The following 2 functions are used by the BlogThread.
 * As the current state, the BlogThread and the MainThread need to have their own separate prepared statements
 */
+ (BOOL)updateUploadStatus:(int)pk withUploadStatus:(int)upload database:(sqlite3 *)db{
	// Compile the query for retrieving post data. See insertNewPostIntoDatabase: for more detail.
	if (set_uploadrow_statement == nil) {
		const char *sql = "UPDATE Post Set UPLOAD_STATUS=? where ID=?";
		if (sqlite3_prepare_v2(db, sql, -1, &set_uploadrow_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		
	}
	
	//Now update the database directly to indicate this record is being uploaded
	sqlite3_bind_int(set_uploadrow_statement, 1, upload);
	sqlite3_bind_int(set_uploadrow_statement, 2, pk);
    
    // Execute the query.
    int success = sqlite3_step(set_uploadrow_statement);
    
	// Reset the query for the next use.
    
	sqlite3_reset(set_uploadrow_statement);
    
	// Handle errors.
    
	if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to update upload status with message '%s'.", sqlite3_errmsg(db));
    }
		
	return YES;
}

+ (Post *)getFirstUploadedPost:(sqlite3 *)db{
	Post *p=nil;
	// Compile the query for retrieving post data. See insertNewPostIntoDatabase: for more detail.
	if (get_uploadingrow_statement == nil) {

		const char *sql = "select ID, TITLE from Post where UPLOAD_STATUS=1";
		if (sqlite3_prepare_v2(db, sql, -1, &get_uploadingrow_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		
		sql = "select ID, TITLE from Post where UPLOAD_STATUS=0 ORDER BY ID limit 1";
		if (sqlite3_prepare_v2(db, sql, -1, &get_uploadrow_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		
	}
	
	//First, see if we have records in the database that has a status of UPLOADING.
	//If So, return.
	if (sqlite3_step(get_uploadingrow_statement) == SQLITE_ROW) {
		int pk = sqlite3_column_int(get_uploadingrow_statement,0);
        char *str = (char *)sqlite3_column_text(get_uploadingrow_statement, 1);
        NSString *title = (str) ? [NSString stringWithUTF8String:str] : @"";
		p = [[[Post alloc] initWithPrimaryKeyTitle:pk title:title database:db] autorelease];	
		
        // Reset the query for the next use.
        sqlite3_reset(get_uploadingrow_statement);
		
		return p;
	}
	
	//If not, pick a row that has not been uploaded
	//
	if (sqlite3_step(get_uploadrow_statement) == SQLITE_ROW) {
		int pk = sqlite3_column_int(get_uploadrow_statement,0);
        char *str = (char *)sqlite3_column_text(get_uploadrow_statement, 1);
        NSString *title = (str) ? [NSString stringWithUTF8String:str] : @"";
		p = [[[Post alloc] initWithPrimaryKeyTitle:pk title:title database:db] autorelease];
		
		// Reset the query for the next use.
        sqlite3_reset(get_uploadrow_statement);

		[Post updateUploadStatus:pk withUploadStatus:POSTUPLOADINDICATOR_UPLOADING database:db];
	}
	return p;
}


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) sqlite3_finalize(insert_statement);
    if (init_statement) sqlite3_finalize(init_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
    if (load_statement) sqlite3_finalize(load_statement);
    if (load_blob_statement) sqlite3_finalize(load_blob_statement);
    if (save_statement) sqlite3_finalize(save_statement);
    if (save_blob_statement) sqlite3_finalize(save_blob_statement);
	if (get_uploadrow_statement) sqlite3_finalize(get_uploadrow_statement);
	if (set_uploadrow_statement) sqlite3_finalize(set_uploadrow_statement);
	if (get_uploadingrow_statement) sqlite3_finalize(get_uploadingrow_statement);
}

// Finalize (delete) all upload related SQLite compiled queries.
+ (void)finalizeUploadStatements {
	if (get_uploadrow_statement) {
		sqlite3_finalize(get_uploadrow_statement);
		get_uploadrow_statement = nil;
	}
	if (set_uploadrow_statement) {
		sqlite3_finalize(set_uploadrow_statement);
		set_uploadrow_statement = nil;
	}
	if (get_uploadingrow_statement) {
		sqlite3_finalize(get_uploadingrow_statement);
		get_uploadingrow_statement = nil;
	}
}

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db {

	NSString *t;
        // Compile the query for retrieving post data. See insertNewPostIntoDatabase: for more detail.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT TITLE FROM Post WHERE ID=?";
            if (sqlite3_prepare_v2(db, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, pk);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			char *cstr = (char *)sqlite3_column_text(init_statement, 0);
            if (cstr != nil) t = [NSString stringWithUTF8String:cstr];
        } else {
            t = @"No title";
        }
        // Reset the statement for future reuse.
	sqlite3_reset(init_statement);
	
	self = [self initWithPrimaryKeyTitle:pk title:t database:db];
    
	return self;
}

- (id)initWithPrimaryKeyTitle:(NSInteger)pk title:(NSString*)t database:(sqlite3 *)db {
    if (self = [super init]) {
        primaryKey = pk;
        database = db;
		uploadIndicator = POSTUPLOADINDICATOR_WAITING;
		self.title = t;
		self.deviceId = [[UIDevice currentDevice] uniqueIdentifier] ;

        dirty = NO;
		imageDirty = NO;
    }
    return self;
}


- (void)insertIntoDatabase:(sqlite3 *)db {
    database = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Post object.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO Post (TITLE, TIME_CREATED) VALUES(?,?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [title UTF8String], -1, SQLITE_TRANSIENT);
	
	[timeCreated release];
	timeCreated = [[NSDate date] copy];
	sqlite3_bind_double(insert_statement, 2, [timeCreated timeIntervalSince1970]);

    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        primaryKey = sqlite3_last_insert_rowid(database);
    }
    // All data for the Post is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
    loaded = YES;

    if (insert_blob_statement == nil) {
        static char *sql = "INSERT INTO PostImage (POSTID) VALUES(?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_blob_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
	sqlite3_bind_int(insert_blob_statement,1,primaryKey);
	
    success = sqlite3_step(insert_blob_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_blob_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    } 
    // All data for the Post is already in memory, but has not be written to the database
    // Mark as hydrated to prevent empty/default values from overwriting what is in memory
	imageLoaded = YES;
}

- (void)dealloc {
	[postId release];
	[deviceId release];
	[title release];
	[description release];
	[thumbnail release];
	[image release];
	[timeCreated release];
	[timePicture release];
	[timeModified release];	
    [super dealloc];
}

- (void)deleteFromDatabase {
    // Compile the delete statement if needed.
    if (delete_statement == nil) {
        const char *sql = "DELETE FROM Post WHERE ID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }

    // Compile the delete statement if needed.
    if (delete_blob_statement == nil) {
        const char *sql = "DELETE FROM PostImage WHERE POSTID=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_blob_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_blob_statement, 1, primaryKey);
    // Execute the query.
	success = sqlite3_step(delete_blob_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_blob_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
    }
	
}

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)load {
    // Check if action is necessary.
	NSLog(@"Loaded=%s",(loaded)?"TRUE":"FALSE");
    if (loaded) return;
    // Compile the hydration statement, if needed. Get everything except for the Image
    if (load_statement == nil) {
        const char *sql = "SELECT TITLE, WP_POST_ID, DEVICE_ID, DESCRIPTION, THUMBNAIL, LAT, LON, ALT, H_ACCURACY, V_ACCURACY, MANUALOVERRIDE, TIME_CREATED, TIME_PICTURE, TIME_MODIFIED, UPLOAD_STATUS FROM Post WHERE ID=?";

        if (sqlite3_prepare_v2(database, sql, -1, &load_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(load_statement, 1, primaryKey);
    // Execute the query.
    int success =sqlite3_step(load_statement);
    if (success == SQLITE_ROW) {

        char *str = (char *)sqlite3_column_text(load_statement, 0);
        self.title = (str) ? [NSString stringWithUTF8String:str] : @"";
		
        str = (char *)sqlite3_column_text(load_statement, 1);
        self.postId = (str) ? [NSString stringWithUTF8String:str] : @"";
		
        str = (char *)sqlite3_column_text(load_statement, 2);
        self.deviceId = (str) ? [NSString stringWithUTF8String:str] : @"";

        str = (char *)sqlite3_column_text(load_statement, 3);
        self.description = (str) ? [NSString stringWithUTF8String:str] : @"";

		int size          = sqlite3_column_bytes(load_statement,4); // bytes returns the size of the blob.
		NSLog(@"Getting image, size=%d",size);
		if (size >0 ) {
			const void *bytes = sqlite3_column_blob(load_statement, 4);	//blob returns a pointer to the blob.	
			NSData *aData = [NSData dataWithBytes:bytes length:size];
			self.thumbnail = [UIImage imageWithData:aData];
		}
		
        self.lat = sqlite3_column_double(load_statement, 5);
        self.lon = sqlite3_column_double(load_statement, 6);
        self.alt = sqlite3_column_double(load_statement, 7);
        self.h_accuracy = sqlite3_column_double(load_statement, 8);
        self.v_accuracy = sqlite3_column_double(load_statement, 9);
		self.manualLocaitonOverride = sqlite3_column_int(load_statement,10);
		
		[timeCreated release];
        timeCreated = [[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(load_statement, 11)] copy];
		
		[timePicture release];
        timePicture = [[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(load_statement, 12)] copy];
		
		[timeModified release];
        timeModified = [[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(load_statement, 13)] copy];
		
		self.uploadIndicator = sqlite3_column_int(load_statement,14);
		
	} 
    // Reset the query for the next use.
    sqlite3_reset(load_statement);
    // Update object state with respect to hydration.
    loaded = YES;
	dirty = NO;
}

// Flushes all but the primary key and title out to the database.
- (void)save{
    if (dirty) {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (save_statement == nil) {
            const char *sql = "UPDATE Post SET WP_POST_ID=?, DEVICE_ID=?, TITLE=?, DESCRIPTION=?, THUMBNAIL=?, LAT=?, LON=?, ALT=?, H_ACCURACY=?, V_ACCURACY=?, MANUALOVERRIDE=?, TIME_MODIFIED=?, UPLOAD_STATUS=? WHERE ID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &save_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
        sqlite3_bind_text(save_statement, 1, (postId)?[postId UTF8String]:"", -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(save_statement, 2, (deviceId)?[deviceId UTF8String]:"", -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(save_statement, 3, (title)?[title UTF8String]:"", -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(save_statement, 4, (description)?[description UTF8String]:"", -1, SQLITE_TRANSIENT);

		NSData *raw = UIImagePNGRepresentation(self.thumbnail);
		const void *bytes = [raw bytes];
		int l = [raw length];
		sqlite3_bind_blob(save_statement, 5, bytes, l, SQLITE_TRANSIENT);
		
        sqlite3_bind_double(save_statement, 6, lat);
        sqlite3_bind_double(save_statement, 7, lon);
        sqlite3_bind_double(save_statement, 8, alt);
        sqlite3_bind_double(save_statement, 8, h_accuracy);
        sqlite3_bind_double(save_statement, 10, v_accuracy);
		sqlite3_bind_int(save_statement, 11, manualLocaitonOverride);
		sqlite3_bind_double(save_statement, 12, [[NSDate date] timeIntervalSince1970]);
		sqlite3_bind_int(save_statement, 13, uploadIndicator);
        sqlite3_bind_int(save_statement, 14, primaryKey);
        // Execute the query.
        int success = sqlite3_step(save_statement);
        // Reset the query for the next use.
        sqlite3_reset(save_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
        // Update the object state with respect to unwritten changes.
        dirty = NO;
    }
    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them 
    // if dehydrate is called multiple times.
	[postId release];
	postId = nil;
	[deviceId release];
	deviceId = nil;
	[title release];
	title = nil;
	[description release];
	description = nil;
	[timeModified release];
	timeModified = nil;
	[thumbnail release];
	thumbnail = nil;
    // Update the object state with respect to hydration.
    loaded = NO;
}

- (void)loadImage {
    // Check if action is necessary.
    if (imageLoaded) return;
    // Compile the hydration statement, if needed. Get everything except for the Image
    if (load_blob_statement == nil) {
        const char *sql = "SELECT IMAGE, TIME_PICTURE FROM PostImage WHERE POSTID=?";
		
        if (sqlite3_prepare_v2(database, sql, -1, &load_blob_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(load_blob_statement, 1, primaryKey);
    // Execute the query.
    int success =sqlite3_step(load_blob_statement);
    if (success == SQLITE_ROW) {
		
		
		int size          = sqlite3_column_bytes(load_blob_statement,0); // bytes returns the size of the blob.
		NSLog(@"Getting image, size=%d",size);
		if (size >0 ) {
			const void *bytes = sqlite3_column_blob(load_blob_statement, 0);	//blob returns a pointer to the blob.	
			NSData *aData = [[NSData dataWithBytes:bytes length:size] copy];
			self.image = [UIImage imageWithData:aData];
		}

		[timePicture release];
        timePicture = [[NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(load_blob_statement, 1)] copy];
				
	} 
    // Reset the query for the next use.
    sqlite3_reset(load_blob_statement);
    // Update object state with respect to hydration.
    imageLoaded = YES;
	imageDirty = NO;
}


// Flushes the image blog out to the database.
- (void)saveImage {
    if (imageDirty) {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (save_blob_statement == nil) {
            const char *sql = "UPDATE PostImage SET IMAGE=?, TIME_PICTURE=? WHERE POSTID=?";
            if (sqlite3_prepare_v2(database, sql, -1, &save_blob_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // Bind the query variables.
		NSData *raw = UIImagePNGRepresentation(image);
		const void *bytes = [raw bytes];
		int l = [raw length];
		sqlite3_bind_blob(save_blob_statement, 1, bytes, l, SQLITE_TRANSIENT);
		sqlite3_bind_double(save_blob_statement, 2, [[NSDate date] timeIntervalSince1970]);
        sqlite3_bind_int(save_blob_statement, 3, primaryKey);
        // Execute the query.
        int success = sqlite3_step(save_blob_statement);
        // Reset the query for the next use.
        sqlite3_reset(save_blob_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
        }
		imageDirty = NO;
    }
    // Release member variables to reclaim memory. Set to nil to avoid over-releasing them 
    // if dehydrate is called multiple times.
	[image autorelease];
	image = nil;
	[timePicture release];
	timePicture = nil;
	imageLoaded = NO;
}


#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSInteger)primaryKey {
    return primaryKey;
}

- (NSString *)title {
    return title;
}

- (void)setTitle:(NSString *)aString {
    if ((!title && !aString) || (title && aString && [title isEqualToString:aString])) return;
    dirty = YES;
    [title release];
    title = [aString copy];
}

- (NSString *)postId {
    return postId;
}

- (void)setPostId:(NSString *)aString {
	
    if ((!postId && !aString) || (postId && aString && [postId isEqualToString:aString])) return;
    dirty = YES;
    [postId release];
    postId = [aString copy];
}

- (NSString *)deviceId {
    return deviceId;
}

- (void)setDeviceId:(NSString *)aString {
	
    if ((!deviceId && !aString) || (deviceId && aString && [deviceId isEqualToString:aString])) return;
    dirty = YES;
    [deviceId release];
    deviceId = [aString copy];
}

- (NSString *)description {
    return description;
}

- (void)setDescription:(NSString *)aString {
    if ((!description && !aString) || (description && aString && [description isEqualToString:aString])) return;
    dirty = YES;
    [description release];
    description = [aString copy];
}

- (UIImage *)image {
    return image;
}

- (void)setImage:(UIImage *)aImage {
    if (!image && !aImage) return;
    imageDirty = YES;
    [image autorelease];
    image = [aImage retain];
}

- (void)setThumbnail:(UIImage *)aImage {
    if (!thumbnail && !aImage) return;
    dirty = YES;
    [thumbnail autorelease];
    thumbnail = [aImage retain];
}


- (double)lat {
		return lat;
}
		
- (void)setLat:(double)aLat {
		dirty = YES;
		lat = aLat;		
}
		
- (double)lon {
	return lon;
}
		
- (void)setLon:(double)aLon {
	dirty = YES;
	lon = aLon;		
}

- (double)alt {
	return alt;
}

- (void)setAlt:(double)aAlt {
	dirty = YES;
	alt = aAlt;		
}

- (double)h_accuracy {
	return h_accuracy;
}

- (void)setH_accuracy:(double)aH_accuracy {
	dirty = YES;
	h_accuracy = aH_accuracy;		
}

- (double)v_accuracy {
	return v_accuracy;
}

- (void)setV_accuracy:(double)aV_accuracy {
	dirty = YES;
	v_accuracy = aV_accuracy;		
}

- (UIImage *)thumbnail{
	return thumbnail;
}

- (NSDate *)timeCreated {
    return timeCreated;
}
- (NSDate *)timePicture {
	return timePicture;
}

- (NSDate *)timeModified {
	return timeModified;
}
		
- (int)uploadIndicator {
	return uploadIndicator;
}

- (void)setUploadIndicator:(int)ind {
	dirty = YES;
	uploadIndicator = ind;		
}

@end

