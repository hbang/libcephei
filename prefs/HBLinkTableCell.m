#import "HBLinkTableCell.h"
#import "Symbols.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIColor+Private.h>
#import <version.h>
#import <HBLog.h>

@implementation HBLinkTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_isBig = specifier.properties[@"big"] ? ((NSNumber *)specifier.properties[@"big"]).boolValue : NO;
		_iconURL = specifier.properties[@"iconURL"];
		if ([_iconURL isKindOfClass:NSString.class]) {
			_iconURL = [NSURL URLWithString:(NSString *)_iconURL];
		}

		self.selectionStyle = IS_IOS_OR_NEWER(iOS_7_0) ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleBlue;

		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"safari" inBundle:cepheiGlobalBundle]];
		if (IS_IOS_OR_NEWER(iOS_7_0)) {
			imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
		if (@available(iOS 13, *)) {
			if (IS_IOS_OR_NEWER(iOS_13_0)) {
				imageView.tintColor = [UIColor systemGray3Color];
			}
		}
		self.accessoryView = imageView;

		self.detailTextLabel.numberOfLines = _isBig ? 0 : 1;
		self.detailTextLabel.text = specifier.properties[@"subtitle"] ?: @"";
		if (IS_IOS_OR_NEWER(iOS_13_0)) {
			if (@available(iOS 13, *)) {
				self.detailTextLabel.textColor = [UIColor secondaryLabelColor];
			}
		} else {
			self.detailTextLabel.textColor = IS_IOS_OR_NEWER(iOS_7_0) ? [UIColor systemGrayColor] : [UIColor tableCellValue1BlueColor];
		}

		self.specifier = specifier;
		if (self.shouldShowIcon) {
			CGFloat iconSize = _isBig ? 40.f : 29.f;
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(iconSize, iconSize), NO, [UIScreen mainScreen].scale);
			specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();

			_iconView = [[UIView alloc] initWithFrame:self.imageView.bounds];
			_iconView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_iconView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
			_iconView.userInteractionEnabled = NO;
			_iconView.clipsToBounds = YES;
			[self.imageView addSubview:_iconView];

			if (specifier.properties[@"initials"]) {
				_iconView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1];

				UILabel *label = [[UILabel alloc] initWithFrame:_iconView.bounds];
				label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				label.font = [UIFont systemFontOfSize:13.f];
				label.textAlignment = NSTextAlignmentCenter;
				label.textColor = [UIColor whiteColor];
				label.text = specifier.properties[@"initials"];
				[_iconView addSubview:label];
			} else {
				_iconImageView = [[UIImageView alloc] initWithFrame:_iconView.bounds];
				_iconImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				_iconImageView.alpha = 0;
				_iconImageView.userInteractionEnabled = NO;
				_iconImageView.layer.minificationFilter = kCAFilterTrilinear;
				[_iconView addSubview:_iconImageView];

				[self loadIconIfNeeded];
			}

			BOOL isIconCircular = specifier.properties[@"iconCircular"] ? ((NSNumber *)specifier.properties[@"iconCircular"]).boolValue : NO;
			CGFloat cornerRadius = 0;
			if (isIconCircular) {
				cornerRadius = iconSize / 2;
			} else {
				cornerRadius = specifier.properties[@"iconCornerRadius"] ? ((NSNumber *)specifier.properties[@"iconCornerRadius"]).doubleValue : -1;
				if (cornerRadius < 0) {
					cornerRadius = 0;
					static NSMutableDictionary <NSNumber *, UIImage *> *iconMasks;
					static dispatch_once_t onceToken;
					dispatch_once(&onceToken, ^{
						iconMasks = [NSMutableDictionary dictionary];
					});

					UIImage *maskImage = iconMasks[@(iconSize)];
					if (maskImage == nil) {
						maskImage = iconFromColorAndGlyph([UIColor whiteColor], _isBig, nil);
						iconMasks[@(iconSize)] = maskImage;
					}
					CALayer *maskLayer = [CALayer layer];
					maskLayer.frame = CGRectMake(0, 0, iconSize, iconSize);
					maskLayer.contents = (__bridge id)maskImage.CGImage;
					_iconView.layer.mask = maskLayer;
				}
			}
			_iconView.layer.cornerRadius = cornerRadius;
		}
	}

	return self;
}

#pragma mark - Icon

- (UIImage *)iconImage {
	return _iconImageView.image;
}

- (void)setIconImage:(UIImage *)iconImage {
	_iconImageView.image = iconImage;

	// Fade in if we haven’t yet
	if (_iconImageView.alpha == 0) {
		[UIView animateWithDuration:0.15 animations:^{
			_iconImageView.alpha = 1;
		}];
	}
}

- (BOOL)shouldShowIcon {
	// If we were explicitly told to show an icon, or if we have an icon URL or initials
	return (self.specifier.properties[@"showIcon"] && ((NSNumber *)self.specifier.properties[@"showIcon"]).boolValue)
		|| (self.specifier.properties[@"showAvatar"] && ((NSNumber *)self.specifier.properties[@"showAvatar"]).boolValue)
		|| self.specifier.properties[@"iconURL"] != nil || self.specifier.properties[@"initials"] != nil;
}

- (void)loadIconIfNeeded {
	if (_iconURL == nil || self.iconImage != nil) {
		return;
	}

	static dispatch_queue_t queue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = dispatch_queue_create("ws.hbang.common.load-icon-queue", DISPATCH_QUEUE_SERIAL);
	});

	dispatch_async(queue, ^{
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_iconURL];
		[request setValue:kHBCepheiUserAgent forHTTPHeaderField:@"User-Agent"];

		void (^completion)(NSData *data, NSURLResponse *response, NSError *error) = ^(NSData *data, NSURLResponse *response, NSError *error) {
			NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
			if (error != nil || statusCode != 200) {
				HBLogWarn(@"Error loading icon (%@): %li %@ - %@", _iconURL.absoluteString, (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode], error);
				[self iconLoadDidFailWithResponse:response error:error];
				return;
			}

			dispatch_async(dispatch_get_main_queue(), ^{
				UIImage *image = [UIImage imageWithData:data];
				if (image == nil) {
					[self iconLoadDidFailWithResponse:response error:error];
				} else {
					self.iconImage = image;
				}
			});
		};

#if ROOTLESS
		[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completion];
#else
		NSError *error = nil;
		NSHTTPURLResponse *response = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		completion(data, response, error);
#endif
	});
}

- (void)iconLoadDidFailWithResponse:(NSURLResponse *)response error:(NSError *)error {
	dispatch_async(dispatch_get_main_queue(), ^{
		BOOL isIconCircular = self.specifier.properties[@"iconCircular"] ? ((NSNumber *)self.specifier.properties[@"iconCircular"]).boolValue : NO;
		CGFloat cornerRadius = self.specifier.properties[@"iconCornerRadius"] ? ((NSNumber *)self.specifier.properties[@"iconCornerRadius"]).doubleValue : -1;
		if (cornerRadius < 0 && !isIconCircular) {
			self.iconImage = [UIImage imageWithCGImage:LICreateDefaultIcon(_isBig ? MIIconVariantSpotlight : MIIconVariantSmall)];
		}
	});
}

@end
