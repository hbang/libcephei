#import "HBTintedTableCell.h"
#import <Preferences/PSSpecifier.h>
#import "../ui/UIColor+HBAdditions.h"

@implementation HBTintedTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
		id tintColorString = specifier.properties[@"tintColor"];
		self.tintColor = [UIColor hb_colorWithPropertyListValue:tintColorString];
	}
	return self;
}

- (void)tintColorDidChange {
	[super tintColorDidChange];

	self.textLabel.textColor = self.tintColor;
	self.textLabel.highlightedTextColor = self.tintColor;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
	[super refreshCellContentsWithSpecifier:specifier];

	self.textLabel.textColor = self.tintColor;
	self.textLabel.highlightedTextColor = self.tintColor;
}

@end
