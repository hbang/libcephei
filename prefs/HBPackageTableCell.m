#import "HBPackageTableCell.h"
#import "../HBOutputForShellCommand.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>

@implementation HBPackageTableCell {
	NSString *_identifier;
	NSString *_repo;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	_identifier = [specifier.properties[@"packageIdentifier"] copy];
	_repo = [specifier.properties[@"packageRepository"] copy];

	NSParameterAssert(_identifier);

	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		((UIImageView *)self.accessoryView).image = [UIImage imageNamed:@"package" inBundle:globalBundle];
		self.avatarView.layer.cornerRadius = 4.f;

		HBLogDebug(@"id %@ repo %@", _identifier, _repo);

		if (_repo) {
			specifier.properties[@"url"] = [NSURL URLWithString:[NSString stringWithFormat:@"cydia://url/https://cydia.saurik.com/api/share#?source=%@&package=%@", URL_ENCODE(_repo), URL_ENCODE(_identifier)]];
		} else {
			specifier.properties[@"url"] = [@"cydia://package/" stringByAppendingPathComponent:_identifier];
		}
	}

	return self;
}

- (BOOL)shouldShowAvatar {
	return YES;
}

- (void)loadAvatarIfNeeded {
	if (self.avatarImage) {
		return;
	}

	void (^getIcon)(NSURL *url) = ^(NSURL *url) {
		NSData *data = [NSData dataWithContentsOfURL:url];

		if (!data) {
			HBLogWarn(@"failed to get package icon for %@", _identifier);
			return;
		}

		UIImage *image = [[UIImage alloc] initWithData:data scale:2];

		if (!image) {
			HBLogWarn(@"failed to read package icon for %@", _identifier);
			return;
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			self.avatarImage = image;
		});
	};

	NSString *iconField = HBOutputForShellCommand([NSString stringWithFormat:@"/usr/bin/dpkg-query -f '${Icon}' -W '%@'", _identifier]);

	if (iconField && ![iconField isEqualToString:@""]) {
		NSURL *iconURL = [NSURL URLWithString:iconField];

		if (!iconURL.isFileURL) {
			HBLogWarn(@"icon url %@ for %@ isn't a file:// url", iconField, _identifier);
			return;
		}

		getIcon(iconURL);
		return;
	}

	if (!_repo) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			getIcon([[[NSURL URLWithString:@"https://cydia.saurik.com/icon/"] URLByAppendingPathComponent:_identifier] URLByAppendingPathExtension:@"png"]);
		});
	}
}

@end
