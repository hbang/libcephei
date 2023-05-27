import UIKit
import Preferences
@_exported import CepheiPrefs_ObjC
@_implementationOnly import CepheiPrefs_Private

extension AboutListController {

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
