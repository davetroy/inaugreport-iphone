#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define POSTUPLOADINDICATOR_WAITING 0
#define POSTUPLOADINDICATOR_UPLOADING 1
#define POSTUPLOADINDICATOR_DONE 2

@interface Post : NSObject {
    // Opaque reference to the underlying database.
    sqlite3 *database;
    // Primary key in the database.
    NSInteger primaryKey;
    // Attributes.
	NSString *postId;
	NSString *deviceId;
	NSString *title;
	NSString *description;
	UIImage  *image;
	UIImage  *thumbnail;
	double     lat;
	double     lon;
	double	   alt;
	double     h_accuracy;
	double     v_accuracy;
	NSDate   *timeCreated;
	NSDate   *timePicture;
	NSDate   *timeModified;
	int		  uploadIndicator;
    
	// Internal state variables. Hydrated tracks whether attribute data is in the object or the database.
    BOOL loaded;
	BOOL imageLoaded;
    // Dirty tracks whether there are in-memory changes to data which have no been written to the database.
    BOOL dirty;
	BOOL imageDirty;
	
	//Transient value
	BOOL manualLocaitonOverride;
}

// Property exposure for primary key and other attributes. The primary key is 'assign' because it is not an object, 
// nonatomic because there is no need for concurrent access, and readonly because it cannot be changed without 
// corrupting the database.
@property (assign, nonatomic, readonly) NSInteger primaryKey;
// The remaining attributes are copied rather than retained because they are value objects.
@property(copy, nonatomic)  NSString *postId;
@property(copy, nonatomic)  NSString *deviceId;
@property(copy, nonatomic)  NSString *title;
@property(copy, nonatomic)  NSString *description;
@property(retain, nonatomic)  UIImage  *image;
@property(retain, nonatomic)  UIImage  *thumbnail;
@property(assign, nonatomic) double   lat;
@property(assign, nonatomic) double   lon;
@property(assign, nonatomic) double   alt;
@property(assign, nonatomic) double   v_accuracy;
@property(assign, nonatomic) double   h_accuracy;
@property(copy, nonatomic, readonly)  NSDate   *timeCreated;
@property(copy, nonatomic, readonly)  NSDate   *timePicture;
@property(copy, nonatomic, readonly)  NSDate   *timeModified;
@property(assign, nonatomic) int   uploadIndicator;
@property(assign, nonatomic) BOOL   manualLocaitonOverride;


// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

// Creates the object with primary key and title is brought into memory.
- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (id)initWithPrimaryKeyTitle:(NSInteger)pk title:(NSString *)title database:(sqlite3 *)db;

// Inserts the book into the database and stores its primary key.
- (void)insertIntoDatabase:(sqlite3 *)database;

// Brings the rest of the object data into memory. If already in memory, no action is taken (harmless no-op).
- (void)load;
- (void)loadImage;
// Flushes all but the primary key and title out to the database.
- (void)save;
- (void)saveImage;
// Remove the book complete from the database. In memory deletion to follow...
- (void)deleteFromDatabase;

//The following 3 functions are used by the BlogThread
+ (Post *)getFirstUploadedPost:(sqlite3 *)db;
+ (BOOL)updateUploadStatus:(int)pk withUploadStatus:(int)upload database:(sqlite3 *)db;
+ (void)finalizeUploadStatements;


@end

