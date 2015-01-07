#import "HBBigImageTableCell.h"
#import <Preferences/PSSpecifier.h>
#import <version.h>

@implementation HBBigImageTableCell {
	UIImageView *_bigImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.backgroundView = IS_MODERN ? nil : [[[UIView alloc] init] autorelease];

		_bigImageView = [[UIImageView alloc] initWithImage:specifier.properties[@"iconImage"]];
		_bigImageView.frame = self.contentView.bounds;
		_bigImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_bigImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:_bigImageView];

		self.imageView.hidden = YES;
		self.textLabel.hidden = YES;
		self.detailTextLabel.hidden = YES;
	}

	return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil specifier:specifier];
	return self;
}

#pragma mark - PSHeaderFooterView

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return _bigImageView.image.size.height;
}

#pragma mark - Memory management

- (void)dealloc {
	[_bigImageView release];
	[super dealloc];
}

@end
