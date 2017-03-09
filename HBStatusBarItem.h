NS_ASSUME_NONNULL_BEGIN

/**************************************************************************************************
 * this is a rough draft of the Cephei Status Bar API. it’s intentionally incompatible with       *
 * libstatusbar – let’s start fresh! a limited lsb compatibility layer is provided, however.      *
 * looking for feedback. ping me on irc (kirb) or twitter (@hbkirb)                               *
 **************************************************************************************************/

typedef NS_ENUM(NSUInteger, HBStatusBarLocation) {
	HBStatusBarLocationLeft,
	HBStatusBarLocationCenter,
	HBStatusBarLocationRight
};

typedef NS_ENUM(NSUInteger, HBStatusBarItemPosition) {
	HBStatusBarItemPositionPriorityFirst,
	HBStatusBarItemPositionFirst,

	HBStatusBarItemPositionBeforeItemIdentifier,
	HBStatusBarItemPositionBeforeSystemItems,
	
	HBStatusBarItemPositionAfterItemIdentifier,
	HBStatusBarItemPositionAfterSystemItems,
	
	HBStatusBarItemPositionLast,
	HBStatusBarItemPositionPriorityLast
};

typedef NS_ENUM(NSUInteger, HBStatusBarItemFontStyle) {
	HBStatusBarItemFontStyleRegular,
	HBStatusBarItemFontStyleBold
};

typedef NS_ENUM(NSUInteger, HBStatusBarItemFontSize) {
	HBStatusBarItemFontSizeRegular,
	HBStatusBarItemFontSizeSmall
};

typedef NS_ENUM(NSUInteger, HBStatusBarItemTextPosition) {
	HBStatusBarItemTextPositionBefore,
	HBStatusBarItemTextPositionCenter,
	HBStatusBarItemTextPositionAfter
};

@interface HBStatusBarItem : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier;
- (instancetype)initWithIdentifier:(NSString *)identifier imageNamed:(nullable NSString *)imageName inBundle:(nullable NSBundle *)bundle;

@property (nonatomic, strong, readonly) NSString *identifier;

@property (nonatomic, assign, getter=isVisible) BOOL visible;

@property (nonatomic, assign) BOOL updateAutomatically;

- (void)update;

@property (nonatomic, assign) HBStatusBarLocation statusBarLocation;
@property (nonatomic, assign) HBStatusBarItemPosition itemPosition;
@property (nonatomic, strong, nullable) NSString *itemPositionIdentifier;
@property (nonatomic, assign) BOOL shouldPreserveOrdering;

@property (nonatomic, strong, nullable) NSString *imageName;
@property (nonatomic, strong, nullable) NSBundle *imageBundle;

@property (nonatomic, strong, nullable) NSString *text;
@property (nonatomic, assign) HBStatusBarItemFontStyle fontStyle;
@property (nonatomic, assign) HBStatusBarItemFontSize fontSize;
@property (nonatomic, assign) HBStatusBarItemTextPosition textPosition;

@property (nonatomic, strong, nullable) NSString *customViewClass;

- (UIImage *)iconForStatusBarHeight:(CGFloat)statusBarHeight;
- (UIImage *)prerenderedIconForStatusBarHeight:(CGFloat)statusBarHeight;

@end

NS_ASSUME_NONNULL_END
