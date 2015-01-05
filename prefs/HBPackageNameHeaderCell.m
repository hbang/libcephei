#import "HBPackageNameHeaderCell.h"
#import "HBOutputForShellCommand.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIViewController+Private.h>
#import <version.h>

static CGFloat const kHBPackageNameTableCellFontSize = 25.f;

@implementation HBPackageNameHeaderCell {
	UIView *_containerView;
	UIImageView *_packageImageView;
	UILabel *_nameLabel;
	UILabel *_versionLabel;

	BOOL _hasLoadedIcon;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.backgroundView = IS_MODERN ? nil : [[[UIView alloc] init] autorelease];

		NSArray *packageData = [HBOutputForShellCommand([NSString stringWithFormat:@"/usr/bin/dpkg-query -f '${Name}\n==libcephei-divider==\n${Version}' -W '%@'", specifier.properties[@"packageIdentifier"]]) componentsSeparatedByString:@"\n==libcephei-divider==\n"];

		_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 44.f)];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self.contentView addSubview:_containerView];

		_packageImageView = [[UIImageView alloc] init];
		[_containerView addSubview:_packageImageView];

		_nameLabel = [[UILabel alloc] init];
		_nameLabel.backgroundColor = [UIColor clearColor];
		_nameLabel.font = [UIFont boldSystemFontOfSize:kHBPackageNameTableCellFontSize];
		[_containerView addSubview:_nameLabel];

		if (!specifier.properties[@"showVersion"] || ((NSNumber *)specifier.properties[@"showVersion"]).boolValue) {
			_versionLabel = [[UILabel alloc] init];
			_versionLabel.backgroundColor = [UIColor clearColor];
			_versionLabel.font = [UIFont systemFontOfSize:kHBPackageNameTableCellFontSize];
			[_containerView addSubview:_versionLabel];
		}

		_nameLabel.text = packageData[0];
		_versionLabel.text = packageData[1];
	}

	return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil specifier:specifier];
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	if (!_hasLoadedIcon) {
		/*
		 there might be somewhere better to do this, and there probably is.
		 it's vital that the view is in the view hierarchy because it must get
		 at the containing view controller so it can get at the bundle that
		 implements that view controller, so it can get at the info plist, so
		 it can get at the bundle name and package identifier, so it can get
		 at the package version from dpkg.
		*/

		UIView *rootView = self.superview;

		while (rootView && ![UIViewController viewControllerForView:rootView]) {
			rootView = rootView.superview;
		}

		NSBundle *bundle = [NSBundle bundleForClass:[UIViewController viewControllerForView:rootView].class];

		_packageImageView.image = [UIImage imageNamed:@"icon" inBundle:bundle];
		[_packageImageView sizeToFit];

		_hasLoadedIcon = YES;
	}

	CGFloat height = _containerView.frame.size.height;

	_nameLabel.frame = CGRectMake(_packageImageView.image.size.width + 10.f, -1.f, [_nameLabel.text sizeWithFont:_nameLabel.font].width, height);
	_versionLabel.frame = CGRectMake(_nameLabel.frame.origin.x + _nameLabel.frame.size.width + 6.f, _nameLabel.frame.origin.y, [_versionLabel.text sizeWithFont:_versionLabel.font].width, height);
	_containerView.frame = CGRectMake(0, 34.f, _versionLabel ? _versionLabel.frame.origin.x + _versionLabel.frame.size.width : _nameLabel.frame.origin.x + _nameLabel.frame.size.width, height);
	_containerView.center = CGPointMake(self.contentView.frame.size.width / 2, _containerView.center.y);
	_packageImageView.center = CGPointMake(_packageImageView.center.x, height / 2);
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 78.f;
}

#pragma mark - Memory management

- (void)dealloc {
	[_containerView release];
	[_packageImageView release];
	[_nameLabel release];
	[_versionLabel release];

	[super dealloc];
}

@end
