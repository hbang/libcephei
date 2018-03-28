NS_ASSUME_NONNULL_BEGIN

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

/**
 * The `HBStatusBarItem` class in `Cephei` provides a simple abstract interface to creating and
 * maintaining an icon displayed in the status bar. Cephei Status Bar APIs can be used from any
 * process that RocketBootstrap is capable of working in.
 *
 * This class is not compatible with the libstatusbar equivalent. LSStatusBarItem and other classes
 * from libstatusbar are provided by Cephei Status Bar as minimal compatibility wrappers.
 *
 * ### File naming convention
 * Cephei Status Bar can display a static image from a specified bundle. It is recommended that this
 * image be in a bundle specific to the tweak, as opposed to being placed in UIKit.framework.
 * However, if no bundle is specified, UIKit’s framework bundle will be used.
 *
 * Supported file names are:
 *
 * * Black_[ItemName].png – required. automatically tinted template based on status bar color
 * * Black_[ItemName]_Color.png – not tinted; colors are preserved
 * * White_[ItemName].png – same as above, but used when the status bar is white
 * * White_[ItemName]_Color.png – same as above
 * * LockScreen_[ItemName].png – required. larger for lock screen status bar
 * * LockScreen_[ItemName]_Color.png – same as above
 *
 * (@2x, @3x, etc. suffixes omitted.) Black and LockScreen images must be provided, and White is
 * optional. [Refer to iPhone Dev Wiki](http://iphonedevwiki.net/index.php/Libstatusbar) for details
 * on image sizes and which are used in specific situations.
 *
 * ### Example usage
 * Basic usage:
 *
 * 	NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/TypeStatus.bundle"];
 * 	HBStatusBarItem *item = [[HBStatusBarItem alloc] initWithIdentifier:@"ws.hbang.typestatus.read" imageNamed:@"TypeStatusRead" inBundle:bundle];
 * 	item.visible = NO;
 * 	[[HBStatusBarController sharedInstance] addItem:item];
 * 	
 * 	// on receiving a notification:
 * 	item.visible = YES;
 *
 * With more customisations:
 *
 * 	NSString *numberOfMessages = @"10";
 * 	HBStatusBarItem *item = [[HBStatusBarItem alloc] initWithIdentifier:@"ws.hbang.common.example-icon"];
 * 	item.imageName = @"UnreadMessages";
 * 	item.imageBundle = [NSBundle bundleWithPath:@"/Library/Application Support/Example.bundle"];
 * 	item.text = numberOfMessages;
 * 	item.statusBarLocation = HBStatusBarLocationCenter;
 * 	item.itemPosition = HBStatusBarItemPositionAfterSystemItems;
 * 	item.fontSize = HBStatusBarItemFontSizeSmall;
 * 	[[HBStatusBarController sharedInstance] addItem:item];
 * 	
 * 	// on receiving new data:
 * 	NSString *numberOfMessages = @"8";
 * 	item.text = numberOfMessages;
 */

@interface HBStatusBarItem : NSObject

/**
 * @name Initializing an HBStatusBarItem Object
 */

/**
 * Initializes an instance of the class for the specified identifier, and optionally sets the image
 * name and bundle.
 *
 * @param identifier The identifier to be used. This should remain consistent and never change for
 * this particular icon.
 * @param imageName The image name to be used. Refer to above for the file naming convention.
 * @param imageBundle The bundle to search for the image in. When nil, the UIKit framework bundle
 * will be used.
 * @returns An autoreleased instance of HBStatusBarItem for the specified identifier.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier imageNamed:(nullable NSString *)imageName inBundle:(nullable NSBundle *)imageBundle;

/**
 * Initializes an instance of the class for the specified identifier.
 *
 * @param identifier The identifier to be used. This should remain consistent and never change for
 * this particular icon.
 * @returns An instance of HBStatusBarItem for the specified identifier.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

/**
 * The identifier provided at initialisation.
 */
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

/**
 * A subclass of HBStatusBarItemView to be used.
 * 
 * The class must be registered at runtime (e.g. with Logos’ `%subclass` directive), because UIKit
 * does not export a symbol for the base UIStatusBarItemView class. The class must be present in
 * all processes linking against UIKit (e.g. by setting the Substrate filter to `com.apple.UIKit`).
 */
@property (nonatomic, strong, nullable) NSString *customViewClass;

/**
 * Called when the icon needs to be retrieved from the item.
 *
 * Override this method and return your own image if you need to perform custom rendering. The
 * default implementation generates an icon based on the properties provided to this class for
 * image name/bundle and text. You can alternatively set customViewClass and subclass (at runtime)
 * HBStatusBarItemView if you need more flexibility.
 *
 * The image will usully be tinted automatically to the color of the status bar. If custom colors
 * are required, set the image’s template mode by using
 * [`-[UIImage imageWithRenderingMode:]`](https://developer.apple.com/reference/uikit/uiimage/1624153-imagewithrenderingmode?language=objc)
 * with the value `UIImageRenderingModeAlwaysOriginal`.
 *
 * @param height The height of the status bar.
 * @param tintColor The color of the status bar items.
 * @return An image to be displayed in the status bar.
 */
- (UIImage *)iconForStatusBarHeight:(CGFloat)height tintColor:(UIColor *)tintColor;

@end

NS_ASSUME_NONNULL_END
