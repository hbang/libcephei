#import "HBPackageTableCell.h"
#import "HBPackage.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

@implementation HBPackageTableCell {
	NSString *_identifier;
	NSString *_repo;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	_identifier = [specifier.properties[@"packageIdentifier"] copy];
	_repo = [specifier.properties[@"packageRepository"] copy];

	NSParameterAssert(_identifier);

	if (specifier.properties[@"iconURL"] == nil) {
		NSURLComponents *canisterURL = [NSURLComponents componentsWithString:@"https://api.canister.me/v1/community/packages"];
		canisterURL.queryItems = @[
			[NSURLQueryItem queryItemWithName:@"id" value:_identifier],
			[NSURLQueryItem queryItemWithName:@"content" value:@"packageIcon"],
			[NSURLQueryItem queryItemWithName:@"redirect" value:@"true"]
		];
		NSURL *iconURL = canisterURL.URL;

		NSString *iconField = getFieldForPackage(_identifier, @"Icon");
		if (iconField && ![iconField isEqualToString:@""]) {
			NSURL *maybeIconURL = [NSURL URLWithString:iconField];
			if (maybeIconURL != nil && (!maybeIconURL.isFileURL || [maybeIconURL checkResourceIsReachableAndReturnError:nil])) {
				iconURL = maybeIconURL;
			}
		}

		specifier.properties[@"iconURL"] = iconURL;
	}

	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		UIImageView *imageView = (UIImageView *)self.accessoryView;
		imageView.image = [UIImage systemImageNamed:@"shippingbox"];
		[imageView sizeToFit];
	}

	return self;
}

- (BOOL)shouldShowIcon {
	return YES;
}

@end
