#import "PostTableCellView.h"

@implementation PostTableCellView

@synthesize title;
@synthesize description;
@synthesize timeModified;
@synthesize timeCreated;
@synthesize image;
@synthesize highlighted;
@synthesize editing;


- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		/*
		 Cache the formatter. Normally you would use one of the date formatter styles (such as NSDateFormatterShortStyle), but here we want a specific format that excludes seconds.
		 */
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM/dd"];
		timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setDateFormat:@"h:mm a"];
		self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}



- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
	if (highlighted != lit) {
		highlighted = lit;	
		[self setNeedsDisplay];
	}
}


- (void)drawRect:(CGRect)rect {

//For Image	
#define LEFT_COLUMN_OFFSET 10
#define LEFT_COLUMN_WIDTH 80

//Title and Description	
#define MIDDLE_COLUMN_OFFSET 140
#define MIDDLE_COLUMN_WIDTH 150
	
#define UPPER_ROW_TOP 8
#define LOWER_ROW_TOP 44
	
#define MAIN_FONT_SIZE 18
#define MIN_MAIN_FONT_SIZE 16
#define SECONDARY_FONT_SIZE 12
#define MIN_SECONDARY_FONT_SIZE 10

	// Color and font for the main text items
	UIColor *mainTextColor = nil;
	UIColor *dateColor = nil;
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];

	// Color and font for the secondary text items
	UIColor *secondaryTextColor = nil;
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
	
	// Choose font color based on highlighted state.
	if (self.highlighted) {
		mainTextColor = [UIColor whiteColor];
		dateColor = [UIColor whiteColor];
		secondaryTextColor = [UIColor whiteColor];
	}
	else {
		mainTextColor = [UIColor blackColor];
		dateColor = [UIColor blueColor];
		secondaryTextColor = [UIColor darkGrayColor];
		self.backgroundColor = [UIColor whiteColor];
	}
	
	CGRect contentRect = self.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern.
    if (!self.editing) {
		
		CGFloat boundsX = contentRect.origin.x;
		CGFloat boundsW = contentRect.size.width;
		CGPoint point;
		
		CGFloat actualFontSize;
		CGSize timeLabelSize;

		// Draw the image
		[image drawInRect: CGRectMake(0.0f, 0.0f, LEFT_COLUMN_WIDTH, LEFT_COLUMN_WIDTH)];
		
		// Set the color for the main text items
		[mainTextColor set];
		
		//Get the size of the time label in order to calulate how much room we have for the title.
		NSTimeInterval interval = [timeCreated timeIntervalSinceNow];
		NSString *timeString;
		if (interval > (60 * 60 *24) /*one day*/){
			timeString = [dateFormatter stringFromDate:timeCreated];
		} else {
			timeString = [timeFormatter stringFromDate:timeCreated];
		}			
		timeLabelSize = [timeString sizeWithFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:&actualFontSize forWidth:MIDDLE_COLUMN_WIDTH lineBreakMode:UILineBreakModeTailTruncation];

		
		/*
		 Draw the title top left; use the NSString UIKit method to scale the font size down if the text does not fit in the given area
		*/
		CGFloat titleX = boundsX + LEFT_COLUMN_OFFSET + LEFT_COLUMN_WIDTH;
		CGFloat titleW = boundsW - titleX - timeLabelSize.width;
		point = CGPointMake(titleX, UPPER_ROW_TOP);
		[title drawAtPoint:point forWidth:titleW withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

		[dateColor set];
		/*
		 Draw the last modified date, right-aligned in the middle column.
		 To ensure it is right-aligned, first find its width with the given font and minimum allowed font size. Then draw the string at the appropriate offset.
		 */
		
		point = CGPointMake(boundsX + contentRect.size.width - timeLabelSize.width, UPPER_ROW_TOP);
		[timeString drawAtPoint:point forWidth:timeLabelSize.width withFont:mainFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
		
		// Set the color for the secondary text items
		[secondaryTextColor set];

		/*
		 Draw the description bottom left; use the NSString UIKit method to scale the font size down if the text does not fit in the given area
		 */
		point = CGPointMake(boundsX + LEFT_COLUMN_OFFSET + 80, LOWER_ROW_TOP);
		[description drawAtPoint:point forWidth: (contentRect.size.width - LEFT_COLUMN_OFFSET - LEFT_COLUMN_WIDTH)  withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeWordWrap baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
	}
}


- (void)dealloc {
	[dateFormatter release];
	[timeFormatter release];
	[title release];
	[description release];
	[timeModified release];
	[image release];
    [super dealloc];
}


@end
