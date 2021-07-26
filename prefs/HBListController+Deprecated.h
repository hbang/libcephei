#import "HBListController.h"

NS_ASSUME_NONNULL_BEGIN

/// Appearance methods implemented on HBListController are not supported on iOS 10.0 and later. Use
/// `HBAppearanceSettings` instead.
@interface HBListController (Deprecated)

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
+ (nullable UIColor *)hb_tintColor __attribute((deprecated("Use HBAppearanceSettings instead.")));

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
+ (nullable UIColor *)hb_navigationBarTintColor __attribute((deprecated("Use HBAppearanceSettings instead.")));

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
+ (BOOL)hb_invertedNavigationBar __attribute((deprecated("Use HBAppearanceSettings instead.")));

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
+ (BOOL)hb_translucentNavigationBar __attribute((deprecated("Use HBAppearanceSettings instead.")));

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
+ (UIColor *)hb_tableViewBackgroundColor __attribute((deprecated("Use HBAppearanceSettings instead.")));

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
+ (UIColor *)hb_tableViewCellTextColor __attribute((deprecated("Use HBAppearanceSettings instead.")));

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
+ (UIColor *)hb_tableViewCellBackgroundColor __attribute((deprecated("Use HBAppearanceSettings instead.")));

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
+ (UIColor *)hb_tableViewCellSeparatorColor __attribute((deprecated("Use HBAppearanceSettings instead.")));

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
+ (UIColor *)hb_tableViewCellSelectionColor __attribute((deprecated("Use HBAppearanceSettings instead.")));

@end

NS_ASSUME_NONNULL_END
