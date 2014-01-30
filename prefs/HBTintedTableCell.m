#import "HBTintedTableCell.h"

@implementation HBTintedTableCell

- (void)layoutSubviews {
	[super layoutSubviews];

	if ([self respondsToSelector:@selector(tintColor)]) {
		self.textLabel.textColor = self.tintColor;
	}
}

@end
