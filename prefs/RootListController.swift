/// The HBRootListController class in CepheiPrefs provides a list controller class that should
/// be used as the root of the package's settings. It includes two class methods you can override to
/// provide a default message and a URL that the user can share via a sharing button displayed to
/// the right of the navigation bar.
///
/// It is recommended that you use this class even if its current features aren’t appealing in case
/// of future improvements or code that relies on the presence of an HBRootListController.

@objc(HBRootListController)
public class RootListController: ListController {

	/// @name Constants

	// TODO: DEPRECATE
	/// A string to be used as a default message when the user shares the package to a friend or social
	/// website. Override this method to return your own string.
	///
	/// If the return value of this method and `hb_shareURL `are nil, the sharing button will not be
	/// displayed.
	///
	/// @return By default, nil.
	@objc(hb_shareText)
	static var shareText: String? { nil }

	/// The URL to be shared when the user shares the package to a friend or social website. Override
	/// this method to return your own URL.
	///
	/// If the return value of this method and `hb_shareText` are nil, the sharing button will not be
	/// displayed.
	///
	/// @return By default, nil.
	@objc(hb_shareURL)
	static var shareURL: URL? { nil }

	@objc(hb_shareText)
	var shareText: String? { Self.shareText }

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
