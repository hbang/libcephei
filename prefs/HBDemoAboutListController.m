#import "HBDemoAboutListController.h"

@implementation HBDemoAboutListController

#pragma mark - PSListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"DemoAbout" target:self] retain];
	}

	return _specifiers;
}

@end
