#import <Preferences/PSListController.h>

/**
 * The `HBListController` class in `CepheiPrefs` provides a list controller with
 * various conveniences such as a unique tint color for the list controllers
 * within a preference bundle, and bug fixes for common issues within the
 * Settings app and Preferences framework. In particular,a bug with the list
 * controller's content disappearing after closing the Settings app and opening
 * it again is worked around, as well as an issue on iOS 7 where in some cases
 * a cell may stay highlighted after being tapped.
 *
 * It includes two class methods you can override to return the name of a
 * Preferences specifier property list, and a tint color for the interactable
 * elements within the list controller.
 */

NS_ASSUME_NONNULL_BEGIN

@interface HBListController : PSListController

/**
 * @name Constants
 */

/**
 * The property list that contains Preference framework specifiers to display
 * as the content of the list controller. Override this method to return the
 * file name of a property list inside your preference bundle, omitting the
 * file extension.
 *
 * If you use this method and override the `specifiers` method, ensure you call
 * the super method with `[super specifiers];` first in your `specifiers`
 * implementation.
 *
 * @returns By default, nil.
 */
+ (nullable NSString *)hb_specifierPlist;

/**
 * The tint color to use for interactable elements within the list controller.
 * Override this method to return a UIColor to use.
 *
 * A nil value will cause no modification of the tint to occur.
 *
 * @returns By default, nil.
 */
+ (nullable UIColor *)hb_tintColor;

/**
 * The tint color to use for the navigation bar buttons, or, if
 * hb_invertedNavigationBar is set, the background of the navigation bar.
 * Override this method to return a UIColor to use, if you don’t want to use the
 * same color as hb_tintColor.
 *
 * A nil value will cause no modification of the navigation bar tint to occur.
 *
 * @returns By default, the return value of hb_tintColor.
 */
+ (nullable UIColor *)hb_navigationBarTintColor;

/**
 * Whether to use an inverted navigation bar. Override this method if you want
 * this behavior.
 *
 * An inverted navigation bar has a tinted background, rather than the buttons
 * being tinted. All other interface elements will be tinted the same.
 *
 * @returns By default, NO.
 */
+ (BOOL)hb_invertedNavigationBar;

// TODO: document this

+ (BOOL)hb_translucentNavigationBar;

+ (UIColor *)hb_tableViewCellTextColor;

+ (UIColor *)hb_tableViewCellBackgroundColor;

+ (UIColor *)hb_tableViewCellSeparatorColor;

+ (UIColor *)hb_tableViewBackgroundColor;

/**
 * @name Related View Controllers
 */

/**
 * Returns the “real” navigation controller for this view controller.
 *
 * As of iOS 8.0, the navigation controller that owns the navigation bar and
 * other responsibilities is actually a parent of `self.navigationController` on
 * iPhone, due to the larger Plus models. The realNavigationController method
 * returns the correct navigation controller.
 *
 * @returns The real navigation controller.
 */
- (UINavigationController *)realNavigationController;

@end

NS_ASSUME_NONNULL_END
