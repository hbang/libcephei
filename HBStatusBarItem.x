#import "HBStatusBarItem.h"
#import "HBStatusBarController.h"
#import "UIStatusBarCustomItem.h"

@interface UIStatusBarCustomItem ()

@property (nonatomic, strong) NSString *_hb_customViewClass;

@end

@implementation HBStatusBarItem {
	BOOL _visible;
	
	NSString *_imageName;
	NSBundle *_imageBundle;

	NSString *_text;
	HBStatusBarItemFontStyle _fontStyle;
	HBStatusBarItemFontSize _fontSize;
	HBStatusBarItemTextPosition _textPosition;
}

#pragma mark - Init

- (instancetype)initWithIdentifier:(NSString *)identifier imageNamed:(nullable NSString *)imageName inBundle:(nullable NSBundle *)imageBundle {
	self = [self init];

	if (self) {
		NSParameterAssert(identifier);

		_identifier = [identifier copy];
		_imageName = [imageName copy];
		_imageBundle = [imageBundle copy];

		[[HBStatusBarController sharedInstance] addItem:self];
		[self update];
	}

	return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
	return [self initWithIdentifier:identifier imageNamed:nil inBundle:nil];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; identifier = %@; imageName = %@%@%@>",
		self.class, self,
		_identifier, _imageName,
		_imageBundle ? @"; imageBundle = " : @"",
		_imageBundle ?: @""];
}

- (void)dealloc {
	[[HBStatusBarController sharedInstance] removeItem:self];
}

#pragma mark - Update

- (void)update {
	// …
}

#pragma mark - Icon

- (UIImage *)iconForStatusBarHeight:(CGFloat)height tintColor:(UIColor *)tintColor {
	// …
	return nil;
}

#pragma mark - Serialize

- (UIStatusBarCustomItem *)statusBarItem {
	UIStatusBarCustomItem *item = [[%c(UIStatusBarCustomItem) alloc] init];
	item.indicatorName = _identifier;
	item._hb_customViewClass = _customViewClass;
	return item;
}

@end
