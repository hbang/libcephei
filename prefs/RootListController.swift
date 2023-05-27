import UIKit
@_exported import CepheiPrefs_ObjC

extension RootListController {

	/// - name: Constants

	/// A string to be used as a default message when the user shares the package to a friend or social
	/// website. Override this method to return your own string.
	///
	/// If the return value of this method and `hb_shareURL `are nil, the sharing button will not be
	/// displayed.
	///
	/// - returns: By default, nil.
	@objc(hb_shareText)
	static var shareText: String? { nil }

	/// The URL to be shared when the user shares the package to a friend or social website. Override
	/// this method to return your own URL.
	///
	/// If the return value of this method and `hb_shareText` are nil, the sharing button will not be
	/// displayed.
	///
	/// - returns: By default, nil.
	@objc(hb_shareURL)
	static var shareURL: URL? { nil }

	/// A string to be used as a default message when the user shares the package to a friend or social
	/// website. Override this method to return your own string.
	///
	/// If the return value of this method and `hb_shareURL `are nil, the sharing button will not be
	/// displayed.
	///
	/// - returns: By default, nil.
	@objc(hb_shareText)
	var shareText: String? { Self.shareText }

	/// The URL to be shared when the user shares the package to a friend or social website. Override
	/// this method to return your own URL.
	///
	/// If the return value of this method and `hb_shareText` are nil, the sharing button will not be
	/// displayed.
	///
	/// - returns: By default, nil.
	@objc(hb_shareURL)
	var shareURL: URL? { Self.shareURL }

	override public func loadView() {
		super.loadView()

		if shareText != nil || shareURL != nil {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"),
																													style: .plain,
																													target: self,
																													action: #selector(shareTapped))
		}
	}

	@objc(hb_shareTapped:)
	func shareTapped(_ sender: UIBarButtonItem?) {
		let items = ([shareText, shareURL] as [Any?])
			.filter { $0 != nil } as [Any]

		let activityViewController = UIActivityViewController(activityItems: items,
																													applicationActivities: nil)
		activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(activityViewController, animated: true)
	}

}
