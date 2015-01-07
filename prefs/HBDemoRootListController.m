#import "HBDemoRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

@implementation HBDemoRootListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return @"DemoRoot";
}

+ (NSString *)hb_shareText {
	return @"libcephei is a great developer library used behind the scenes of jailbroken iOS packages.";
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"https://hbang.github.io/libcephei"];
}

+ (UIColor *)hb_tintColor {
	return [UIColor purpleColor];
}

#pragma mark - Actions

- (void)doStuffTapped:(PSSpecifier *)specifier {
	PSTableCell *cell = (PSTableCell *)[(UITableView *)self.view cellForRowAtIndexPath:[self indexPathForSpecifier:specifier]];
	cell.cellEnabled = NO;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		cell.cellEnabled = YES;
	});
}

@end
