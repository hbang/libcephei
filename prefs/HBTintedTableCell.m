#import "HBTintedTableCell.h"

@implementation HBTintedTableCell

- (void)tintColorDidChange {
	[super tintColorDidChange];
	self.textLabel.textColor = self.tintColor;
}

@end
