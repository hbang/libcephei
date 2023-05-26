import UIKit

/// The HBAppearanceSettings class in CepheiPrefs provides a model object read by other components
/// of Cephei to determine colors and other appearence settings to use in the user interface.
///
/// Appearance settings are typically set on a view controller, via the
/// `-[PSListController(HBTintAdditions) hb_appearanceSettings]` property. This is automatically
/// managed by Cephei and provided to view controllers as they are pushed onto the stack.
///
/// Most commonly, the API will be used by setting the `hb_appearanceSettings` property from the
/// init method. The following example sets the tint color, table view background color, and
/// customises the navigation bar with a background, title, and status bar color:
///
/// ```swift
/// init() {
/// 	super.init()
///
/// 	let appearanceSettings = AppearanceSettings()
/// 	appearanceSettings.tintColor = UIColor(red: 66 / 255, green: 105 / 255, blue: 154 / 255, alpha: 1)
/// 	appearanceSettings.barTintColor = .systemRed
/// 	appearanceSettings.navigationBarTitleColor = .white
/// 	appearanceSettings.tableViewBackgroundColor = UIColor(white: 242 / 255, alpha: 1)
/// 	appearanceSettings.statusBarStyle = .lightContent
/// 	self.appearanceSettings = appearanceSettings
/// }
/// ```
///
/// ```objc
/// - (instancetype)init {
/// 	self = [super init];
///
/// 	if (self) {
/// 		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
/// 		appearanceSettings.tintColor = [UIColor colorWithRed:66.f / 255.f green:105.f / 255.f blue:154.f / 255.f alpha:1];
/// 		appearanceSettings.barTintColor = [UIColor systemRedColor];
/// 		appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
/// 		appearanceSettings.tableViewBackgroundColor = [UIColor colorWithWhite:242.f / 255.f alpha:1];
/// 		appearanceSettings.statusBarStyle = UIStatusBarStyleLightContent;
/// 		self.hb_appearanceSettings = appearanceSettings;
/// 	}
///
/// 	return self;
/// }
/// ```

@objc(HBAppearanceSettings)
public class AppearanceSettings: NSObject {

	/// Constants indicating how to size the title of this item.
	@objc(HBAppearanceSettingsLargeTitleStyle)
	public enum LargeTitleStyle: UInt {
		/// Display a large title only when the current view controller is a subclass of
		/// `HBRootListController`.
		///
		/// This is the default mode.
		case rootOnly

		/// Always display a large title.
		case always

		/// Never display a large title.
		case never
	}

	/// @name General

	/// The tint color to use for interactable elements within the list controller. Set this property to
	/// a UIColor to use.
	///
	/// A nil value will cause no modification of the tint to occur.
	///
	/// @return By default, nil.
	@objc public var tintColor: UIColor?

	/// The user interface style to use. Set this property to a UIUserInterfaceStyle to use.
	///
	/// @return By default, UIUserInterfaceStyleUnspecified.
	@objc public var userInterfaceStyle: UIUserInterfaceStyle = .unspecified

	/// @name Navigation Bar

	/// The tint color to use for the navigation bar buttons, or, if invertedNavigationBar is set, the
	/// background of the navigation bar. Set this property to a UIColor to use, if you don’t want to
	/// use the same color as tintColor.
	///
	/// A nil value will cause no modification of the navigation bar tint to occur.
	///
	/// @return By default, nil.
	@objc public var navigationBarTintColor: UIColor?

	/// The color to use for the navigation bar title label. Set this property to a UIColor to use.
	///
	/// A nil value will cause no modification of the navigation bar title color to occur.
	///
	/// @return By default, nil.
	@objc public var navigationBarTitleColor: UIColor?

	/// The background color to use for the navigation bar. Set this property to a UIColor to use.
	///
	/// A nil value will cause no modification of the navigation bar background to occur.
	///
	/// @return By default, nil.
	@objc public var navigationBarBackgroundColor: UIColor?

	/// The status bar style to use. Set this property to a UIStatusBarStyle to use.
	///
	/// @return By default, UIStatusBarStyleDefault.
	@objc public var statusBarStyle: UIStatusBarStyle = .default

	/// Whether to show the shadow (separator line) at the bottom of the navigation bar.
	///
	/// Requires iOS 13 or later.
	///
	/// @return By default, YES.
	@objc public var showsNavigationBarShadow = true

	/// Whether to use a large title on iOS 11 and newer. Set this property to a value from
	/// HBAppearanceSettingsLargeTitleStyle.
	///
	/// @return By default, HBAppearanceSettingsLargeTitleStyleRootOnly.
	@objc public var largeTitleStyle: LargeTitleStyle = .rootOnly

	/// @name Table View

	/// The color to be used for the overall background of the table view. Set this property to a
	/// UIColor to use.
	///
	/// @return By default, nil.
	@objc public var tableViewBackgroundColor: UIColor?

	/// The color to be used for the text color of table view cells. Set this property to a UIColor to
	/// use.
	///
	/// @return By default, nil.
	@objc public var tableViewCellTextColor: UIColor?

	/// The color to be used for the background color of table view cells. Set this property to a
	/// UIColor to use.
	///
	/// @return By default, nil.
	@objc public var tableViewCellBackgroundColor: UIColor?

	/// The color to be used for the separator between table view cells. Set this property to a UIColor
	/// to use.
	///
	/// @return By default, nil.
	@objc public var tableViewCellSeparatorColor: UIColor?

	/// The color to be used when a table view cell is selected. This color will be shown when the cell
	/// is in the highlighted state.
	///
	/// @return By default, nil.
	@objc public var tableViewCellSelectionColor: UIColor?

}

extension AppearanceSettings: NSCopying {
	@objc public func copy(with zone: NSZone? = nil) -> Any {
		let appearanceSettings = AppearanceSettings()
		appearanceSettings.tintColor = tintColor
		appearanceSettings.userInterfaceStyle = userInterfaceStyle
		appearanceSettings.navigationBarTintColor = navigationBarTintColor
		appearanceSettings.navigationBarTitleColor = navigationBarTitleColor
		appearanceSettings.navigationBarBackgroundColor = navigationBarBackgroundColor
		appearanceSettings.statusBarStyle = statusBarStyle
		appearanceSettings.showsNavigationBarShadow = showsNavigationBarShadow
		appearanceSettings.largeTitleStyle = largeTitleStyle
		appearanceSettings.tableViewBackgroundColor = tableViewBackgroundColor
		appearanceSettings.tableViewCellTextColor = tableViewCellTextColor
		appearanceSettings.tableViewCellBackgroundColor = tableViewCellBackgroundColor
		appearanceSettings.tableViewCellSeparatorColor = tableViewCellSeparatorColor
		appearanceSettings.tableViewCellSelectionColor = tableViewCellSelectionColor
		return appearanceSettings
	}
}
