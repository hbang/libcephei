#import "HBPackageTableCell.h"
#import "HBPackage.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>
#import <HBLog.h>
#import <version.h>

@implementation HBPackageTableCell {
	NSString *_identifier;
	NSString *_repo;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	_identifier = [specifier.properties[@"packageIdentifier"] copy];
	_repo = [specifier.properties[@"packageRepository"] copy];

	NSParameterAssert(_identifier);

	if (specifier.properties[@"iconCornerRadius"] == nil) {
		specifier.properties[@"iconCornerRadius"] = @-1;
	}

	if (specifier.properties[@"iconURL"] == nil) {
		NSURL *iconURL = [[NSURL URLWithString:@"https://proxy.prcl.app/package/"] URLByAppendingPathComponent:_identifier];
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
		imageView.image = [UIImage imageNamed:@"package" inBundle:cepheiGlobalBundle];
		if (IS_IOS_OR_NEWER(iOS_7_0)) {
			imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		}
		[imageView sizeToFit];
	}

	return self;
}

- (BOOL)shouldShowIcon {
	return YES;
}

- (void)iconLoadDidFailWithResponse:(NSURLResponse *)response error:(NSError *)error {
	self.specifier.properties[@"_hb_parcilityReturnedNotFound"] = @YES;
	[super iconLoadDidFailWithResponse:response error:error];
}

@end
