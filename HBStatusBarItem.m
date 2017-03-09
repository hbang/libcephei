#import "HBStatusBarItem.h"

@implementation HBStatusBarItem

#pragma mark - Init

- (instancetype)initWithIdentifier:(NSString *)identifier imageNamed:(nullable NSString *)imageName inBundle:(nullable NSBundle *)bundle {
	self = [self init];

	if (self) {
		// …
	}

	return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
	return [self initWithIdentifier:identifier imageNamed:nil inBundle:nil];
}

#pragma mark - Update

- (void)update {
	// …
}

#pragma mark - Icon

- (UIImage *)iconForStatusBarHeight:(CGFloat)statusBarHeight {
	// …
	return nil;
}

- (UIImage *)prerenderedIconForStatusBarHeight:(CGFloat)statusBarHeight {
	return nil;
}

@end
