#import "HBLinkTableCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>
#import <HBLog.h>

@implementation HBLinkTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_isBig = specifier.properties[@"big"] && ((NSNumber *)specifier.properties[@"big"]).boolValue;
		_isAvatarCircular = specifier.properties[@"avatarCircular"] && ((NSNumber *)specifier.properties[@"avatarCircular"]).boolValue;
		_avatarURL = [NSURL URLWithString:specifier.properties[@"avatarURL"]];

		self.selectionStyle = UITableViewCellSelectionStyleBlue;

		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"safari" inBundle:globalBundle]];
		if (IS_IOS_OR_NEWER(iOS_7_0)) {
			imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
		if (@available(iOS 13.0, *)) {
			if (IS_IOS_OR_NEWER(iOS_13_0)) {
				imageView.tintColor = [UIColor systemGray3Color];
			}
		}
		self.accessoryView = imageView;

		self.detailTextLabel.numberOfLines = _isBig ? 0 : 1;
		self.detailTextLabel.text = specifier.properties[@"subtitle"] ?: @"";
		if (IS_IOS_OR_NEWER(iOS_13_0)) {
			if (@available(iOS 13.0, *)) {
				self.detailTextLabel.textColor = [UIColor secondaryLabelColor];
			}
		} else {
			self.detailTextLabel.textColor = IS_IOS_OR_NEWER(iOS_7_0) ? [UIColor systemGrayColor] : [UIColor tableCellValue1BlueColor];
		}

		self.specifier = specifier;
		if (self.shouldShowAvatar) {NSLog(@"avatar? %i %@", self.shouldShowAvatar, self.specifier.properties);
			CGFloat size = _isBig ? 38.f : 29.f;

			UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
			specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();

			_avatarView = [[UIView alloc] initWithFrame:self.imageView.bounds];
			_avatarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_avatarView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
			_avatarView.userInteractionEnabled = NO;
			_avatarView.clipsToBounds = YES;
			[self.imageView addSubview:_avatarView];

			if (specifier.properties[@"initials"]) {
				_avatarView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];

				UILabel *label = [[UILabel alloc] initWithFrame:_avatarView.bounds];
				label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				label.font = [UIFont systemFontOfSize:13.f];
				label.textAlignment = NSTextAlignmentCenter;
				label.textColor = [UIColor whiteColor];
				label.text = specifier.properties[@"initials"];
				[_avatarView addSubview:label];
			} else {
				_avatarImageView = [[UIImageView alloc] initWithFrame:_avatarView.bounds];
				_avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				_avatarImageView.alpha = 0;
				_avatarImageView.userInteractionEnabled = NO;
				_avatarImageView.layer.minificationFilter = kCAFilterTrilinear;
				[_avatarView addSubview:_avatarImageView];

				if (_avatarURL != nil) {
					if (specifier.properties[@"avatarCircular"] == nil) {
						_isAvatarCircular = YES;
					}
				}

				[self loadAvatarIfNeeded];
			}

			_avatarView.layer.cornerRadius = IS_IOS_OR_NEWER(iOS_7_0) ? size / 2 : 4.f;
		}
	}

	return self;
}

#pragma mark - Avatar

- (UIImage *)avatarImage {
	return _avatarImageView.image;
}

- (void)setAvatarImage:(UIImage *)avatarImage {
	_avatarImageView.image = avatarImage;

	// Fade in if we haven’t yet
	if (_avatarImageView.alpha == 0) {
		[UIView animateWithDuration:0.15 animations:^{
			_avatarImageView.alpha = 1;
		}];
	}
}

- (BOOL)shouldShowAvatar {
	// If we were explicitly told to show an avatar, or if we have an avatar URL or initials
	return (self.specifier.properties[@"showAvatar"] && ((NSNumber *)self.specifier.properties[@"showAvatar"]).boolValue)
		|| self.specifier.properties[@"avatarURL"] != nil || self.specifier.properties[@"initials"] != nil;
}

- (void)loadAvatarIfNeeded {
	if (_avatarURL == nil || self.avatarImage != nil) {
		return;
	}

	static dispatch_queue_t queue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = dispatch_queue_create("ws.hbang.common.load-avatar-queue", DISPATCH_QUEUE_SERIAL);
	});

	dispatch_async(queue, ^{
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_avatarURL];
		if ([_avatarURL.host rangeOfString:@"twitter.com"].location != NSNotFound) {
			// I usually wouldn’t do this, it’s kinda rude to straight up lie and pretend to be a browser
			// from 20 years ago. But Twitter has made it incredibly hard to get at profile pics, and I’m
			// pretty sick of something as innocent as a profile photo being impossible to get at without
			// forcing the app to get the user to authenticate to the API first… which is clearly stupid.
			// So yeah sorry not sorry Twitter. Be less horrible to the little guys and I’ll change this.
			// https://github.com/hbang/libcephei/issues/38
			[request setValue:@"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)" forHTTPHeaderField:@"User-Agent"];
		}
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

		if (error != nil) {
			HBLogError(@"Error loading avatar: %@", error);
			return;
		}

		UIImage *image = [UIImage imageWithData:data];

		dispatch_async(dispatch_get_main_queue(), ^{
			self.avatarImage = image;
		});
	});
}

@end
