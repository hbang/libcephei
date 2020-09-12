#import "HBTwitterCell.h"
#import "../NSString+HBAdditions.h"
#import "../NSDictionary+HBAdditions.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>
#import <HBLog.h>

#if __has_include("TwitterAPI.private.h")
	#import "TwitterAPI.private.h"
	#import "HBTwitterAPIClient.h"
#endif

#ifdef CEPHEI_TWITTER_BEARER_TOKEN
	#define USE_TWITTER_API_CLIENT IS_IOS_OR_NEWER(iOS_7_0)
#else
	#define USE_TWITTER_API_CLIENT NO
#endif

@interface HBLinkTableCell ()

- (BOOL)shouldShowIcon;

@end

@interface HBTwitterCell () <HBTwitterAPIClientDelegate> {
	NSString *_user;
}

@end

@implementation HBTwitterCell

+ (NSURL *)_urlForUsername:(NSString *)username userID:(NSString *)userID {
	NSDictionary <NSString *, NSString *> *query = userID == nil
		? @{
			@"screen_name": username
		}
		: @{
			@"user_id": userID
		};
	return [NSURL URLWithString:[@"https://twitter.com/intent/user?" stringByAppendingString:query.hb_queryString]];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	NSString *userName = [specifier.properties[@"user"] copy];
	NSString *userID = [specifier.properties[@"userID"] copy];

	if (specifier.properties[@"iconURL"] == nil) {
		if (USE_TWITTER_API_CLIENT) {
			NSAssert(userName != nil || userID != nil, @"user or userID not provided");
		} else {
			NSAssert(userName != nil, @"user not provided");
			NSString *escapedUsername = userName.hb_stringByEncodingQueryPercentEscapes;
			NSString *size = [UIScreen mainScreen].scale > 2 ? @"original" : @"bigger";
			specifier.properties[@"iconURL"] = [NSString stringWithFormat:@"https://mobile.twitter.com/%@/profile_image?size=%@", escapedUsername, size];
		}
	}
	if (specifier.properties[@"iconCircular"] == nil) {
		specifier.properties[@"iconCircular"] = @YES;
	}
	specifier.properties[@"url"] = [self.class _urlForUsername:userName userID:userID];

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_user = userName;

		UIImageView *imageView = (UIImageView *)self.accessoryView;
		imageView.image = [UIImage imageNamed:@"twitter" inBundle:cepheiGlobalBundle];
		if (IS_IOS_OR_NEWER(iOS_7_0)) {
			imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
		[imageView sizeToFit];

		self.detailTextLabel.text = [@"@" stringByAppendingString:_user];

#ifdef CEPHEI_TWITTER_BEARER_TOKEN
		if (USE_TWITTER_API_CLIENT) {
			[[HBTwitterAPIClient sharedInstance] addDelegate:self forUsername:userName userID:userID];
		}
#endif
	}

	return self;
}

- (BOOL)shouldShowIcon {
	// HBLinkTableCell doesn’t want avatars by default, but we do. Override its check method so that
	// if showAvatar and showIcon are unset, we return YES.
	return self.specifier.properties[@"showAvatar"] || self.specifier.properties[@"showIcon"] ? [super shouldShowIcon] : YES;
}

#ifdef CEPHEI_TWITTER_BEARER_TOKEN
- (void)prepareForReuse {
	[super prepareForReuse];

	// Make sure an earlier request for user metadata doesn’t overwrite the incoming cell.
	[[HBTwitterAPIClient sharedInstance] removeDelegate:self forUsername:self.specifier.properties[@"user"] userID:self.specifier.properties[@"userID"]];
}

- (void)twitterAPIClientDidLoadUsername:(NSString *)username profileImage:(UIImage *)profileImage {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.iconImage = profileImage;
		_user = username;
		self.detailTextLabel.text = [@"@" stringByAppendingString:username];
	});
}

- (void)dealloc {
	[[HBTwitterAPIClient sharedInstance] removeDelegate:self forUsername:nil userID:nil];
}
#endif

@end
