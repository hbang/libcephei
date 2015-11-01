#import "HBInitialsLinkTableCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>

@implementation HBInitialsLinkTableCell {
	NSURL *_url;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"safari" inBundle:globalBundle]];

		_url = [[NSURL alloc] initWithString:specifier.properties[@"url"]];

		NSAssert(_url, @"No URL was provided to HBInitialsLinkTableCell.");

		if (specifier.properties[@"initials"]) {
			CGFloat size = 29.f;

			UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
			specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();

			UIView *avatarView = [[[UIView alloc] initWithFrame:CGRectMake(15.f, 0, size, size)] autorelease];
			avatarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
			avatarView.center = CGPointMake(avatarView.center.x, self.contentView.frame.size.height / 2);
			avatarView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
			avatarView.userInteractionEnabled = NO;
			avatarView.clipsToBounds = YES;
			avatarView.layer.cornerRadius = size / 2;
			[self.contentView addSubview:avatarView];

			UILabel *label = [[[UILabel alloc] initWithFrame:avatarView.bounds] autorelease];
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.font = [UIFont systemFontOfSize:13.f];
			label.textAlignment = NSTextAlignmentCenter;
			label.textColor = [UIColor whiteColor];
			label.text = specifier.properties[@"initials"];
			[avatarView addSubview:label];
		}
	}

	return self;
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)style {
	[super setSelectionStyle:UITableViewCellSelectionStyleDefault];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (!selected) {
		[super setSelected:selected animated:animated];
		return;
	}

	[[UIApplication sharedApplication] openURL:_url];
}

#pragma mark - Memory management

- (void)dealloc {
	[_url release];
	[super dealloc];
}

@end
