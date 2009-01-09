#import <UIKit/UIKit.h>


@interface PostTableCellView : UIView {
	NSString *title;
	NSString *description;
	NSDate *timeModified;
	NSDate *timeCreated;
	UIImage *image;
	BOOL highlighted;
	BOOL editing;
	NSDateFormatter *dateFormatter;
	NSDateFormatter *timeFormatter;
	
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSDate *timeModified;
@property (nonatomic, retain) NSDate *timeCreated;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isEditing) BOOL editing;

@end
