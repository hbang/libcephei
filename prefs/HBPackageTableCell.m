#import "HBPackageTableCell.h"
#import "../HBOutputForShellCommand.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>

@implementation HBPackageTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		((UIImageView *)self.accessoryView).image = [UIImage imageNamed:@"package" inBundle:globalBundle];
		self.avatarView.layer.cornerRadius = 4.f;

		NSString *identifier = self.specifier.properties[@"packageIdentifier"];
		NSString *repo = self.specifier.properties[@"packageRepository"];

		NSParameterAssert(identifier);

		if (repo) {
			specifier.properties[@"url"] = [NSURL URLWithString:[NSString stringWithFormat:@"cydia://url/https://cydia.saurik.com/api/share#?source=%@&package=%@", URL_ENCODE(repo), URL_ENCODE(identifier)]];
		} else {
			specifier.properties[@"url"] = [@"cydia://package/" stringByAppendingPathComponent:identifier];
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

	NSString *identifier = self.specifier.properties[@"packageIdentifier"];
	NSString *repo = self.specifier.properties[@"packageRepository"];

	void (^getIcon)(NSString *identifier, NSURL *url) = ^(NSString *identifier, NSURL *url) {
		NSData *data = [NSData dataWithContentsOfURL:url];

		if (!data) {
			HBLogWarn(@"failed to get package icon for %@", identifier);
			return;
		}

		UIImage *image = [[UIImage alloc] initWithData:data scale:2];

		if (!image) {
			HBLogWarn(@"failed to read package icon for %@", identifier);
			return;
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			self.avatarImage = image;
		});
	};

	NSString *iconField = HBOutputForShellCommand([NSString stringWithFormat:@"/usr/bin/dpkg-query -f '${Icon}' -W '%@'", identifier]);

	if (iconField && ![iconField isEqualToString:@""]) {
		NSURL *iconURL = [NSURL URLWithString:iconField];

		if (!iconURL.isFileURL) {
			HBLogWarn(@"icon url %@ for %@ isn't a file:// url", iconField, identifier);
			return;
		}

		getIcon(identifier, iconURL);
		return;
	}

	if (!repo) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			getIcon(identifier, [[[NSURL URLWithString:@"https://cydia.saurik.com/icon/"] URLByAppendingPathComponent:identifier] URLByAppendingPathExtension:@"png"]);
		});
	}
}

@end
