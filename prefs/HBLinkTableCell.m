#import "HBLinkTableCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

@implementation HBLinkTableCell {
	UIImageView *_avatarImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	// if we are big, we need to know right now so we can set the style
	BOOL isBig = specifier.properties[@"big"] && ((NSNumber *)specifier.properties[@"big"]).boolValue;

	self = [super initWithStyle:isBig ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_isBig = isBig;

		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"safari" inBundle:globalBundle]];

		self.detailTextLabel.numberOfLines = isBig ? 0 : 1;
		self.detailTextLabel.text = specifier.properties[@"subtitle"] ?: @"";
		self.detailTextLabel.textColor = IS_MODERN ? [UIColor colorWithWhite:142.f / 255.f alpha:1] : [UIColor tableCellValue1BlueColor];

		if (self._shouldShowAvatar) {
			CGFloat size = isBig ? 38.f : 29.f;

			UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
			specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();

			UIView *avatarView = [[UIView alloc] initWithFrame:self.imageView.bounds];
			avatarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			avatarView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
			avatarView.userInteractionEnabled = NO;
			avatarView.clipsToBounds = YES;
			avatarView.layer.cornerRadius = IS_MODERN ? size / 2 : 4.f;
			[self.imageView addSubview:avatarView];

			if (specifier.properties[@"initials"]) {
				avatarView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];

				UILabel *label = [[UILabel alloc] initWithFrame:avatarView.bounds];
				label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				label.font = [UIFont systemFontOfSize:13.f];
				label.textAlignment = NSTextAlignmentCenter;
				label.textColor = [UIColor whiteColor];
				label.text = specifier.properties[@"initials"];
				[avatarView addSubview:label];
			} else {
				_avatarImageView = [[UIImageView alloc] initWithFrame:avatarView.bounds];
				_avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				_avatarImageView.alpha = 0;
				_avatarImageView.userInteractionEnabled = NO;
				_avatarImageView.layer.minificationFilter = kCAFilterTrilinear;
				[avatarView addSubview:_avatarImageView];

				[self loadAvatarIfNeeded];
			}
		}
	}

	return self;
}

#pragma mark - Avatar

- (UIImage *)avatarImage {
	return _avatarImageView.image;
}

- (void)setAvatarImage:(UIImage *)avatarImage {
	// set the image on the image view
	_avatarImageView.image = avatarImage;

	// if we haven’t faded in yet
	if (_avatarImageView.alpha == 0) {
		// do so now
		[UIView animateWithDuration:0.15 animations:^{
			_avatarImageView.alpha = 1;
		}];
	}
}

- (BOOL)_shouldShowAvatar {
	// if showAvatar is non-nil and YES, use that value. otherwise, if initials
	// is non-nil, return YES
	return (self.specifier.properties[@"showAvatar"] && ((NSNumber *)self.specifier.properties[@"showAvatar"]).boolValue) ||
		self.specifier.properties[@"initials"];
}

- (void)loadAvatarIfNeeded {
	// stub for subclasses
}

@end
