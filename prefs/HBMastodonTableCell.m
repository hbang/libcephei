#import "HBMastodonTableCell.h"
#import <Preferences/PSSpecifier.h>
#import "CepheiPrefs-Swift.h"

static NSString *const kHBMastodonTableCellAccountRegex = @"^@?([a-zA-Z0-9_]+)@([a-zA-Z0-9_]+\\.[a-zA-Z0-9_]+)$";

@interface HBLinkTableCell ()
- (BOOL)shouldShowIcon;
@end

@interface HBMastodonTableCell () <HBMastodonAPIClientDelegate>
@end

@implementation HBMastodonTableCell {
	NSString *_account;
}

+ (NSURL *)_urlForAccount:(NSString *)account {
	static NSRegularExpression *regex;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		regex = [NSRegularExpression regularExpressionWithPattern:kHBMastodonTableCellAccountRegex options:kNilOptions error:nil];
	});

	NSParameterAssert(account != nil);

	NSTextCheckingResult *match = [regex firstMatchInString:account options:kNilOptions range:NSMakeRange(0, account.length)];
	if (match == nil) {
		return nil;
	}
	NSString *username = [account substringWithRange:[match rangeAtIndex:0]];
	NSString *domain = [account substringWithRange:[match rangeAtIndex:1]];
	return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/@%@", domain, username]];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	NSString *account = [specifier.properties[@"account"] copy];

	if (specifier.properties[@"iconURL"] == nil) {
		NSAssert(account != nil, @"account not provided");
	}
	if (specifier.properties[@"iconCircular"] == nil) {
		specifier.properties[@"iconCircular"] = @YES;
	}
	specifier.properties[@"url"] = [self.class _urlForAccount:account];

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_account = account;

		UIImageView *imageView = (UIImageView *)self.accessoryView;
		imageView.image = [[UIImage imageNamed:@"mastodon" inBundle:cepheiGlobalBundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		[imageView sizeToFit];

		self.detailTextLabel.text = _account;

		[[HBMastodonAPIClient sharedInstance] addDelegate:self forAccount:_account];
		[[HBMastodonAPIClient sharedInstance] queueLookupForAccount:_account];
	}

	return self;
}

- (BOOL)shouldShowIcon {
	// HBLinkTableCell doesn’t want avatars by default, but we do. Override its check method so that
	// if showAvatar and showIcon are unset, we return YES.
	return self.specifier.properties[@"showAvatar"] || self.specifier.properties[@"showIcon"] ? [super shouldShowIcon] : YES;
}

- (void)prepareForReuse {
	[super prepareForReuse];

	// Make sure an earlier request for user metadata doesn’t overwrite the incoming cell.
	[[HBMastodonAPIClient sharedInstance] removeDelegate:self forAccount:self.specifier.properties[@"account"]];
}

- (void)mastodonAPIClientDidLoadWithAccount:(NSString *)account actualAccount:(NSString *)actualAccount url:(NSURL *)url profileImage:(UIImage *)profileImage {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (![account isEqualToString:_account]) {
			return;
		}

		_account = [actualAccount copy];
		self.iconImage = profileImage;
		self.detailTextLabel.text = _account;
		self.specifier.properties[@"url"] = url;
	});
}

- (void)dealloc {
	[[HBMastodonAPIClient sharedInstance] removeDelegate:self forAccount:nil];
}

@end
