#import "PostTableCell.h"
#import "PostTableCellView.h"
#import "Post.h"

#define ACTIVITYINDICATORSIZE 25
#define ICONSIZE 16
#define ROW_HEIGHT 80

@implementation PostTableCell

@synthesize postTableCellView;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		
		// Create a post view and add it as a subview of self's contentView.
		CGRect tzvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		postTableCellView = [[[PostTableCellView alloc] initWithFrame:tzvFrame] autorelease];
		postTableCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:postTableCellView];
		
		CGRect spinFrame = CGRectMake(self.contentView.bounds.size.width - ACTIVITYINDICATORSIZE,ROW_HEIGHT - ACTIVITYINDICATORSIZE,ACTIVITYINDICATORSIZE,ACTIVITYINDICATORSIZE);
		serverActivityView = [[UIActivityIndicatorView alloc] initWithFrame:spinFrame];
		serverActivityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		serverActivityView.hidesWhenStopped = YES;
		[self.contentView addSubview:serverActivityView];
		
		// create the initial image view
		CGRect iconFrame = CGRectMake(self.contentView.bounds.size.width - ACTIVITYINDICATORSIZE,ROW_HEIGHT - ACTIVITYINDICATORSIZE,ICONSIZE,ICONSIZE);
		serverStatusView = [[UIImageView alloc] initWithFrame:iconFrame];
		NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"hourglass" ofType:@"png"];
		UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
		serverStatusView.image = image;
		[self.contentView addSubview:serverStatusView];

		// create the anchor image view
		CGRect anchorIconFrame = CGRectMake(self.contentView.bounds.size.width - ACTIVITYINDICATORSIZE - ACTIVITYINDICATORSIZE,ROW_HEIGHT - ACTIVITYINDICATORSIZE,ICONSIZE,ICONSIZE);
		anchorView = [[UIImageView alloc] initWithFrame:anchorIconFrame];
		imagePath = [[NSBundle mainBundle] pathForResource:@"pushpin" ofType:@"jpg"];
		image = [UIImage imageWithContentsOfFile:imagePath];
		anchorView.image = image;
		[self.contentView addSubview:anchorView];
		
	}
	return self;
}
- (void) setTitle:(NSString *)title{
	postTableCellView.title = title;
	[postTableCellView setNeedsDisplay];
}
- (void) setDescription:(NSString *)description{
	postTableCellView.description = description;
}
- (void) setTimeModified:(NSDate *)timeModified{
	postTableCellView.timeModified = timeModified;
}
- (void) setTimeCreated:(NSDate *)timeCreated{
	postTableCellView.timeCreated = timeCreated;
}
- (void) setImage:(UIImage *)image{
	if (image==nil){
		NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"txt_entry" ofType:@"png"];
		image = [UIImage imageWithContentsOfFile:imagePath];
	}
	postTableCellView.image = image;
}

- (int) uploadIndicator{
	return uploadIndicator;
}

- (void) setUploadIndicator:(int)indicator{
	NSString *imagePath;
	UIImage *image;
		switch (indicator) {
			case POSTUPLOADINDICATOR_WAITING:
				imagePath = [[NSBundle mainBundle] pathForResource:@"hourglass" ofType:@"png"];
				image = [UIImage imageWithContentsOfFile:imagePath];
				serverStatusView.image = image;
				serverStatusView.hidden = NO;
				[serverActivityView stopAnimating];
				break;
			case POSTUPLOADINDICATOR_UPLOADING:
				serverStatusView.hidden = YES;
				[serverActivityView startAnimating];
				break;
			case POSTUPLOADINDICATOR_DONE:
				imagePath = [[NSBundle mainBundle] pathForResource:@"done" ofType:@"jpg"];
				image = [UIImage imageWithContentsOfFile:imagePath];
				serverStatusView.image = image;
				serverStatusView.hidden = NO;
				[serverActivityView stopAnimating];
				break;				
			default:
				break;
		}
	uploadIndicator = indicator;
}

- (BOOL) anchor{
	return anchor;
}

- (void) setAnchor:(BOOL)anAnchor{	
	anchor = anAnchor;
	anchorView.hidden = !anchor;
}



- (void)dealloc {
    [super dealloc];
	[postTableCellView release];
	[serverActivityView release];
	[serverStatusView release];
	[anchorView release];
}


@end
