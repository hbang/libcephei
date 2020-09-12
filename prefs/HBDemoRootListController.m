#import "HBDemoRootListController.h"
#import "HBAppearanceSettings.h"
#import "../ui/UIColor+HBAdditions.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <version.h>

@implementation HBDemoRootListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return @"DemoRoot";
}

+ (NSString *)hb_shareText {
	return @"Cephei is a great developer library used behind the scenes of jailbroken iOS packages.";
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"https://hbang.github.io/libcephei/"];
}

#pragma mark - PSListController

- (void)viewDidLoad {
	[super viewDidLoad];


	HBAppearanceSettings *appearance = [[HBAppearanceSettings alloc] init];
	if (IS_IOS_OR_NEWER(iOS_7_0)) {
		UIColor *purpleColor = [UIColor respondsToSelector:@selector(systemPurpleColor)] ? [UIColor systemPurpleColor] : [UIColor purpleColor];
		appearance.tintColor = [purpleColor hb_colorWithDarkInterfaceVariant:[UIColor systemPinkColor]];
		if (@available(iOS 13, *)) {
			appearance.userInterfaceStyle = UIUserInterfaceStyleDark;
		}
		appearance.navigationBarTintColor = [UIColor systemYellowColor];
		appearance.navigationBarBackgroundColor = [purpleColor hb_colorWithDarkInterfaceVariant:[UIColor systemPinkColor]];
		appearance.navigationBarTitleColor = [UIColor whiteColor];
		appearance.statusBarStyle = UIStatusBarStyleLightContent;
		appearance.showsNavigationBarShadow = NO;
		appearance.largeTitleStyle = HBAppearanceSettingsLargeTitleStyleAlways;
		appearance.tableViewCellTextColor = [UIColor whiteColor];
		appearance.tableViewCellBackgroundColor = [UIColor colorWithWhite:22.f / 255.f alpha:1];
		appearance.tableViewCellSeparatorColor = [UIColor colorWithWhite:38.f / 255.f alpha:1];
		appearance.tableViewCellSelectionColor = [UIColor colorWithWhite:46.f / 255.f alpha:1];
		appearance.tableViewBackgroundColor = [UIColor colorWithWhite:44.f / 255.f alpha:1];
	}
	self.hb_appearanceSettings = appearance;
}

#pragma mark - Actions

- (void)doStuffTapped:(PSSpecifier *)specifier {
	PSTableCell *cell = [self cachedCellForSpecifier:specifier];
	cell.cellEnabled = NO;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		cell.cellEnabled = YES;
	});
}

@end
