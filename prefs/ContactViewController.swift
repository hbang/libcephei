import UIKit
import Cephei
import MessageUI
@_exported import CepheiPrefs_ObjC
@_implementationOnly import CepheiPrefs_Private

@objc(HBContactViewController)
public class ContactViewController: ListController {

	@objc public var to: String?
	@objc public var subject: String?
	@objc public var messageBody: String?
	@objc public var preferencesPlist: Data?
	@objc public var preferencesIdentifier: String?

	private var hasShown = false

	public init() {
		super.init(nibName: nil, bundle: nil)
		modalPresentationStyle = .overCurrentContext
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func viewDidLoad() {
		super.viewDidLoad()

		if navigationController == nil || navigationController?.viewControllers.count == 1 {
			view.isHidden = true
		}
	}

	override public func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if hasShown {
			return
		}

		// No use doing this if we can’t send email.
		if !MFMailComposeViewController.canSendMail() {
			let alertController = UIAlertController(title: .localize("NO_EMAIL_ACCOUNTS_TITLE", tableName: "Support"),
																							message: .localize("NO_EMAIL_ACCOUNTS_BODY", tableName: "Support"),
																							preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: .ok, style: .cancel, handler: { _ in self.dismiss() }))
			present(alertController, animated: true, completion: nil)
			return
		}

		let viewController = MFMailComposeViewController()
		viewController.mailComposeDelegate = self
		viewController.setToRecipients([to ?? ""])
		viewController.setSubject(subject ?? "")
		viewController.setMessageBody(messageBody ?? "", isHTML: false)

		if let packageListData = HBOutputForShellCommand("\(installPrefix)/usr/bin/dpkg -l")?.data(using: .utf8) {
			viewController.addAttachmentData(packageListData, mimeType: "text/plain", fileName: "Package List.txt")
		}

		if let preferencesPlist = preferencesPlist,
			 let preferencesIdentifier = preferencesIdentifier {
			viewController.addAttachmentData(preferencesPlist, mimeType: "text/plain", fileName: "preferences-\(preferencesIdentifier).plist")
		}

		viewController.navigationBar.tintColor = appearanceSettings?.navigationBarTintColor ?? view.tintColor
		viewController.navigationBar.barTintColor = appearanceSettings?.navigationBarBackgroundColor
		viewController.view.tintColor = view.tintColor

		present(viewController, animated: true, completion: nil)
		hasShown = true
	}

	private func dismiss() {
		if navigationController == nil || navigationController?.viewControllers.count == 1 {
			dismiss(animated: false, completion: nil)
		} else {
			realNavigationController?.popViewController(animated: true)
		}
	}

}

extension ContactViewController: MFMailComposeViewControllerDelegate {
	public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
		dismiss()
	}
}

