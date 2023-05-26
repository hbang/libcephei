import UIKit
import Preferences
@_exported import CepheiPrefs_ObjC
@_implementationOnly import CepheiPrefs_Private

/// The HBAboutListController class in CepheiPrefs provides a list controller with functions
/// that would typically be used on an "about" page. It includes two class methods you can override
/// to provide a developer website and donation URL, and a class method to provide an email address
/// so the user can send the developer an email right from the tweak's settings.
///
/// There is a sample of an HBAboutListController implemented in the Cephei demo preferences. See
/// the Cephei readme for details.
///
/// ### Example Usage
/// ```xml
/// <dict>
/// 	<key>cell</key>
/// 	<string>PSLinkCell</string>
/// 	<key>cellClass</key>
/// 	<string>HBLinkTableCell</string>
/// 	<key>label</key>
/// 	<string>Visit Website</string>
/// 	<key>url</key>
/// 	<string>https://hashbang.productions/</string>
/// </dict>
/// <dict>
/// 	<key>cell</key>
/// 	<string>PSGroupCell</string>
/// 	<key>label</key>
/// 	<string>Experiencing issues?</string>
/// </dict>
/// <dict>
/// 	<key>action</key>
/// 	<string>hb_sendSupportEmail</string>
/// 	<key>cell</key>
/// 	<string>PSLinkCell</string>
/// 	<key>label</key>
/// 	<string>Email Support</string>
/// </dict>
/// <dict>
/// 	<key>cell</key>
/// 	<string>PSGroupCell</string>
/// 	<key>footerText</key>
/// 	<string>If you like this tweak, please consider a donation.</string>
/// </dict>
/// <dict>
/// 	<key>cell</key>
/// 	<string>PSLinkCell</string>
/// 	<key>cellClass</key>
/// 	<string>HBLinkTableCell</string>
/// 	<key>label</key>
/// 	<string>Donate</string>
/// 	<key>url</key>
/// 	<string>https://hashbang.productions/donate/</string>
/// </dict>
/// ```

@objc(HBAboutListController)
public class AboutListController: ListController {

	public override var specifierPlist: String? { "About" }

	/// - name: Constants

	/// The email address to use in the support email composer form. Override this method to return an
	/// email address.
	///
	/// If this method returns nil, the package’s author email address is used.
	///
	/// - returns: By default, nil.
	@objc(hb_supportEmailAddress)
	public static var supportEmailAddress: String? { nil }

	/// The email address to use in the support email composer form. Override this method to return an
	/// email address.
	///
	/// If this method returns nil, the package’s author email address is used.
	///
	/// - returns: By default, nil.
	@objc(hb_supportEmailAddress)
	public var supportEmailAddress: String? { Self.supportEmailAddress }

	/// Displays a support composer form.
	///
	/// The `-hb_supportEmailAddress` method provides the appropriate parameters to
	/// `HBSupportController`.
	///
	/// - see: `HBSupportController`
	@objc(hb_sendSupportEmail)
	public func _sendSupportEmailObjC() {
		sendSupportEmail(nil)
	}

	/// Displays a support composer form.
	///
	/// The `-hb_supportEmailAddress` method provides the appropriate parameters to
	/// `HBSupportController`.
	///
	/// - see: `HBSupportController`
	@objc(hb_sendSupportEmail:)
	public func sendSupportEmail(_ sender: PSSpecifier? = nil) {
		let viewController = SupportController.supportViewController(for: Bundle(for: Self.self),
																																 preferencesIdentifier: specifier?.properties["defaults"] as? String,
																																 sendToEmail: supportEmailAddress) as! ListController
		viewController.appearanceSettings = appearanceSettings
		viewController.overrideUserInterfaceStyle = overrideUserInterfaceStyle
		realNavigationController?.present(viewController, animated: false)
	}

}
