#import <UIKit/UIKit.h>



@class PostTableCellView;

@interface PostTableCell : UITableViewCell {
	PostTableCellView *postTableCellView;
	UIActivityIndicatorView *serverActivityView;
	UIImageView *serverStatusView;
	UIImageView *anchorView;
	int uploadIndicator;
	BOOL anchor;
}

 @property (nonatomic, retain) PostTableCellView *postTableCellView;
 @property (nonatomic, assign) int uploadIndicator;
 @property (nonatomic, assign) BOOL anchor;

- (void) setTitle:(NSString *)title;
- (void) setDescription:(NSString *)description;
- (void) setTimeModified:(NSDate *)timeModified;
- (void) setTimeCreated:(NSDate *)timeCreated;
- (void) setImage:(UIImage *)image;


@end
