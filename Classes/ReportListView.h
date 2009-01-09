#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BlogThread.h"



@interface ReportListView : UITableViewController <UITableViewDataSource, UITableViewDelegate, BlogThreadDelegate> {
	IBOutlet UIActivityIndicatorView *spinIndicator;
	IBOutlet UIView *backgroundProcessView;
	
	NSMutableArray *contentArray;
	UIActivityIndicatorView *serverActivity;
	
	BlogThread *blogThread;
}

@property (nonatomic, readonly) NSMutableArray *contentArray;

- (void)loadContent;



@end
