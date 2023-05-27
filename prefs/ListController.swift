import UIKit
import Preferences
@_exported import CepheiPrefs_ObjC
@_implementationOnly import CepheiPrefs_Private

extension ListController {

	/// - name: Specifiers

	// TODO: DEPRECATE
	/// The property list that contains Preference framework specifiers to display as the content of the
	/// list controller. Override this method to return the file name of a property list inside your
	/// preference bundle, omitting the file extension.
	///
	/// Example:
	///
	/// ```swift
	/// override var specifierPlist: String { "Root" }
	/// ```
	///
	/// ```objc
	/// + (NSString *)hb_specifierPlist {
	/// 	return @"Root";
	/// }
	/// ```
	///
	/// If you use this method and override the `specifiers` method, ensure you call the super method
	/// with `[super specifiers];` first in your `specifiers` implementation.
	///
	/// - returns: By default, nil.
	@objc(hb_specifierPlist)
	static var specifierPlist: String? { nil }

	@objc(hb_specifierPlist)
	var specifierPlist: String? { Self.specifierPlist }

	private var _specifiers: NSMutableArray? {
		get { value(forKey: "_specifiers") as? NSMutableArray }
		set { setValue(newValue, forKey: "_specifiers") }
	}

	override open var specifiers: NSMutableArray? {
		get {
			if _specifiers == nil {
				if let specifierPlist = specifierPlist,
					 let specifiers = loadSpecifiers(fromPlistName: specifierPlist, target: self) {
					_specifiers = specifiers
				}
			}
			return _specifiers
		}

		set {}
	}

	override public func loadSpecifiers(fromPlistName name: String, target: PSListController?) -> NSMutableArray? {
		let specifiers = super.loadSpecifiers(fromPlistName: name, target: target)
		return configureSpecifiers(specifiers)
	}

	override public func loadSpecifiers(fromPlistName name: String, target: PSListController?, bundle: Bundle?) -> NSMutableArray? {
		let specifiers = super.loadSpecifiers(fromPlistName: name, target: target, bundle: bundle)
		return configureSpecifiers(specifiers)
	}

	private func configureSpecifiers(_ specifiers: NSMutableArray?) -> NSMutableArray {
		guard var specifiers = specifiers as? [PSSpecifier] else {
			return []
		}

		for specifier in specifiers {
			if let filter = specifier.properties?["pl_filter"] as? [String: Any],
				 let versionFilter = filter["CoreFoundationVersion"] as? [Double] {
				let min = versionFilter[0]
				let max = versionFilter.count == 2 ? versionFilter[1] : .greatestFiniteMagnitude

				if kCFCoreFoundationVersionNumber < min || kCFCoreFoundationVersionNumber >= max {
					specifiers.removeAll { $0 == specifier }
				}
			}

			if let cellClass = specifier.properties?[PSCellClassKey] as? AnyClass,
				 cellClass.isSubclass(of: LinkTableCell.self) && specifier.buttonAction == nil {
				// Override the type and action to our own.
				specifier.cellType = .linkCell
				let action: Selector
				if cellClass.isSubclass(of: PackageTableCell.self) {
					action = #selector(openPackage)
				} else if cellClass.isSubclass(of: MastodonTableCell.self) {
					action = #selector(openMastodon)
				} else {
					action = #selector(openURL)
				}
				specifier.buttonAction = action
			}

			// Support for SF Symbols (system images)
			if let iconImageSystem = specifier.properties?["iconImageSystem"] as? [String: Any],
				 let iconImage = SymbolRenderer.symbolImage(from: iconImageSystem) {
				specifier.properties?["iconImage"] = iconImage
			}

			if let leftImageSystem = specifier.properties?["leftImageSystem"] as? [String: Any],
				 let leftImage = SymbolRenderer.symbolImage(from: leftImageSystem) {
				specifier.properties?["leftImage"] = leftImage
			}

			if let rightImageSystem = specifier.properties?["rightImageSystem"] as? [String: Any],
				 let rightImage = SymbolRenderer.symbolImage(from: rightImageSystem) {
				specifier.properties?["rightImage"] = rightImage
			}
		}
		return (specifiers as NSArray).mutableCopy() as! NSMutableArray
	}

	/// - name: Related View Controllers

	/// Returns the “real” navigation controller for this view controller.
	///
	/// As of iOS 8, the navigation controller that owns the navigation bar and other responsibilities
	/// is actually a parent of `self.navigationController` on iPhone, due to the larger Plus models.
	/// The realNavigationController method returns the correct navigation controller.
	///
	/// - returns: The real navigation controller.
	@objc var realNavigationController: UINavigationController? {
		navigationController?.navigationController ?? navigationController
	}

}
