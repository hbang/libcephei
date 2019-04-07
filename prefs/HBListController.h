#import <Preferences/PSListController.h>
#import "PSListController+HBTintAdditions.h"

NS_ASSUME_NONNULL_BEGIN

/// The `HBListController` class in `CepheiPrefs` provides a list controller with various
/// conveniences such as a unique tint color for the list controllers within a preference bundle,
/// and bug fixes for common issues within the Settings app and Preferences framework. In
/// particular, a bug with the list controller’s content disappearing after closing the Settings
/// app and opening it again is worked around, as well as an issue on iOS 7 where in some cases a
/// cell may stay highlighted after being tapped.
///
/// It includes two class methods you can override to return the name of a Preferences specifier
/// property list, and various methods to set custom colors in the list controller interface.

@interface HBListController : PSListController

/// @name Specifiers

/// The property list that contains Preference framework specifiers to display as the content of the
/// list controller. Override this method to return the file name of a property list inside your
/// preference bundle, omitting the file extension.
///
/// If you use this method and override the `specifiers` method, ensure you call the super method
/// with `[super specifiers];` first in your `specifiers` implementation.
///
/// @return By default, nil.
+ (nullable NSString *)hb_specifierPlist;

/// @name Colors

/// The tint color to use for interactable elements within the list controller. Override this method
/// to return a UIColor to use.
///
/// A nil value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, nil.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (nullable UIColor *)hb_tintColor __attribute((deprecated("Use HBAppearance instead.")));

/// The tint color to use for the navigation bar buttons, or, if hb_invertedNavigationBar is set,
/// the background of the navigation bar. Override this method to return a UIColor to use, if you
/// don’t want to use the same color as hb_tintColor.
///
/// A nil value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, the return value of hb_tintColor.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (nullable UIColor *)hb_navigationBarTintColor __attribute((deprecated("Use HBAppearance instead.")));

/// Whether to use an inverted navigation bar. Override this method if you want this behavior.
///
/// An inverted navigation bar has a tinted background, rather than the buttons being tinted. All
/// other interface elements will be tinted the same.
///
/// A NO value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, NO.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (BOOL)hb_invertedNavigationBar __attribute((deprecated("Use HBAppearance instead.")));

/// Whether to use a translucent navigation bar. Override this method if you want
/// this behavior.
///
/// A nil value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, YES.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (BOOL)hb_translucentNavigationBar __attribute((deprecated("Use HBAppearance instead.")));

/// The color to be used for the overall background of the table view. Override
/// this method to return a UIColor to use.
///
/// A nil value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, nil.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (UIColor *)hb_tableViewBackgroundColor __attribute((deprecated("Use HBAppearance instead.")));

/// The color to be used for the text color of table view cells. Override this
/// method to return a UIColor to use.
///
/// A nil value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, nil.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (UIColor *)hb_tableViewCellTextColor __attribute((deprecated("Use HBAppearance instead.")));

/// The color to be used for the background color of table view cells. Override
/// this method to return a UIColor to use.
///
/// A nil value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, nil.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (UIColor *)hb_tableViewCellBackgroundColor __attribute((deprecated("Use HBAppearance instead.")));

/// The color to be used for the separator between table view cells. Override this method to
/// return a UIColor to use.
///
/// A nil value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, nil.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (UIColor *)hb_tableViewCellSeparatorColor __attribute((deprecated("Use HBAppearance instead.")));

/// The color to be used when a table view cell is selected. This color will be used when the cell
/// is in the highlighted state.
///
/// A nil value will cause prior view controllers on the stack to be consulted for a value. If a
/// value is found, that will be used.
///
/// @return By default, nil.
/// @warning Appearance methods on HBListController are deprecated. Use of these methods will result
/// in a warning being logged. Additionally, if any of these methods return nil, previous view
/// controllers on the stack are consulted. This can cause an undesired mix of color schemes. It is
/// advised to switch to using HBAppearanceSettings.
+ (UIColor *)hb_tableViewCellSelectionColor __attribute((deprecated("Use HBAppearance instead.")));

/// @name Related View Controllers

/// Returns the “real” navigation controller for this view controller.
///
/// As of iOS 8.0, the navigation controller that owns the navigation bar and other responsibilities
/// is actually a parent of `self.navigationController` on iPhone, due to the larger Plus models.
/// The realNavigationController method returns the correct navigation controller.
///
/// @return The real navigation controller.
- (UINavigationController *)realNavigationController;

@end

NS_ASSUME_NONNULL_END
