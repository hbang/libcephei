#import "LSStatusBarItem.h"

static NSMutableDictionary *KnownItems;

@implementation LSStatusBarItem {
	UIStatusBarCustomItemAlignment _alignment;

	BOOL _visible;
	NSString *_imageName;
}

#pragma mark - NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier alignment:(UIStatusBarCustomItemAlignment)alignment {
	self = [self init];

	if (self) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			KnownItems = [[NSMutableDictionary alloc] init];
		});

		NSParameterAssert(identifier);
		NSParameterAssert(alignment);

		_identifier = [identifier copy];
		_alignment = alignment;

		KnownItems[_identifier] = self;

		self.imageName = _identifier;
	}

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; identifier = %@; imageName = %@>", self.class, self, _identifier, _imageName];
}

#pragma mark - Properties

- (BOOL)isVisible {
	return _visible;
}

- (void)setVisible:(BOOL)visible {
	_visible = visible;

	if (!_manualUpdate) {
		[self update];
	}
}

- (NSString *)imageName {
	return _imageName;
}

- (void)setImageName:(NSString *)imageName {
	_imageName = [imageName copy];

	if (!_manualUpdate) {
		[self update];
	}
}

#pragma mark - Update

- (void)update {
	HBLogError(@"update: not implemented");
}

#pragma mark - Memory management

- (void)dealloc {
	[KnownItems removeObjectForKey:_identifier];

	[_identifier release];
	[_imageName release];

	[super dealloc];
}

@end
