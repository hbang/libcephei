#import "LSStatusBarItem.h"
#import "_HBStatusBarClient.h"

static NSMutableDictionary *KnownItems;

@interface LSStatusBarItem ()

@property (nonatomic, retain) NSString *_hb_identifier;

@property (nonatomic, assign) UIStatusBarCustomItemAlignment _hb_alignment;

@property (nonatomic, assign) BOOL _hb_visible;
@property (nonatomic, retain) NSString *_hb_imageName;

@property (nonatomic, assign) BOOL _hb_manualUpdate;

@end

%subclass LSStatusBarItem : NSObject

%property (nonatomic, retain) NSString *_hb_identifier;

%property (nonatomic, retain) NSInteger _hb_alignment;

%property (nonatomic, retain) BOOL _hb_visible;
%property (nonatomic, retain) NSString *_hb_imageName;

%property (nonatomic, retain) BOOL _hb_manualUpdate;

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

		self._hb_identifier = [identifier copy];
		self._hb_alignment = alignment;

		KnownItems[self._hb_identifier] = self;

		self.imageName = self._hb_identifier;
	}

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; identifier = %@; imageName = %@>", self.class, self, self._hb_identifier, self._hb_imageName];
}

#pragma mark - Properties

- (BOOL)isVisible {
	return self._hb_visible;
}

- (void)setVisible:(BOOL)visible {
	self._hb_visible = visible;

	if (!self._hb_manualUpdate) {
		[self update];
	}
}

- (NSString *)imageName {
	return self._hb_imageName;
}

- (void)setImageName:(NSString *)imageName {
	self._hb_imageName = [imageName copy];

	if (!self._hb_manualUpdate) {
		[self update];
	}
}

#pragma mark - Update

- (void)update {
	HBLogError(@"update: not implemented");
}

#pragma mark - Memory management

- (void)dealloc {
	[KnownItems removeObjectForKey:self._hb_identifier];
}

%end

%ctor {
	if (![_HBStatusBarClient hasLibstatusbar]) {
		%init;
	}
}
