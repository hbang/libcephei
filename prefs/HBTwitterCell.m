#import "HBTwitterCell.h"
#import "../NSString+HBAdditions.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

@interface HBLinkTableCell ()

- (BOOL)shouldShowAvatar;

@end

@interface HBTwitterCell () {
	NSString *_user;
}

@end

@implementation HBTwitterCell

+ (NSString *)_urlForUsername:(NSString *)user {
#ifdef THEOS
	// not really the right thing for this, but your usernames aren't meant to have weird ass
	// characters in them anyway :p
	user = user.hb_stringByEncodingQueryPercentEscapes;

	// wow, people still copy paste this code
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"aphelion://"]]) {
		return [@"aphelion://profile/" stringByAppendingString:user];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
		return [@"tweetbot:///user_profile/" stringByAppendingString:user];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
		return [@"twitterrific:///profile?screen_name=" stringByAppendingString:user];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings://"]]) {
		return [@"tweetings:///user?screen_name=" stringByAppendingString:user];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
		return [@"twitter://user?screen_name=" stringByAppendingString:user];
	} else {
		return [@"https://mobile.twitter.com/" stringByAppendingString:user];
	}
#else
	return nil;
#endif
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	NSString *user = [specifier.properties[@"user"] copy];
	if (specifier.properties[@"avatarURL"] == nil) {
		NSAssert(user != nil, @"User name not provided");
		NSString *username = user.hb_stringByEncodingQueryPercentEscapes;
		NSString *size = [UIScreen mainScreen].scale > 2 ? @"original" : @"bigger";
		specifier.properties[@"avatarURL"] = [NSString stringWithFormat:@"https://mobile.twitter.com/%@/profile_image?size=%@", username, size];
	}
	specifier.properties[@"url"] = [self.class _urlForUsername:user];

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_user = user;

		UIImageView *imageView = (UIImageView *)self.accessoryView;
		imageView.image = [UIImage imageNamed:@"twitter" inBundle:globalBundle];
		if (IS_IOS_OR_NEWER(iOS_7_0)) {
			imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
		[imageView sizeToFit];

		self.detailTextLabel.text = [@"@" stringByAppendingString:_user];
	}

	return self;
}

- (BOOL)shouldShowAvatar {
	// HBLinkTableCell doesn’t want avatars by default, but we do. override its check method so that
	// if showAvatar is unset, we return YES
	return self.specifier.properties[@"showAvatar"] ? [super shouldShowAvatar] : YES;
}

@end
