import SafariServices
import os.log

fileprivate protocol URLConvertible {
	var url: URL? { get }
}

extension String: URLConvertible {
	var url: URL? { URL(string: self) }
}

extension NSString: URLConvertible {
	var url: URL? { URL(string: self as String) }
}

extension URL: URLConvertible {
	var url: URL? { self }
}

extension NSURL: URLConvertible {
	var url: URL? { self as URL }
}

public extension ListController {

	// MARK: - Respring

	/// Specifier action to perform a restart of the system app (respring).
	///
	/// You should prefer to have preferences immediately take effect, rather than using this method.
	///
	/// @see `-hb_respringAndReturn:`
	@objc(hb_respring:)
	func respring(specifier: PSSpecifier?) {
		handleRespring(andReturn: false, specifier: specifier)
	}

	/// Specifier action to perform a restart of the system app (respring), and return to the current
	/// preferences screen.
	///
	/// You should prefer to have preferences immediately take effect, rather than using this method.
	///
	/// @see `-hb_respring:`
	@objc(hb_respringAndReturn:)
	func respringAndReturn(specifier: PSSpecifier?) {
		handleRespring(andReturn: true, specifier: specifier)
	}

	private func handleRespring(andReturn: Bool, specifier: PSSpecifier?) {
		// Disable the cell, in case it takes a moment
		if let specifier = specifier,
			 let cell = cachedCell(for: specifier) {
			cell.cellEnabled = false
		}

		RespringController.respring(returnURL: andReturn ? RespringController._preferencesReturnURL() : nil)
	}

	// MARK: - Open URL

	/// Specifier action to open the URL specified by the specifier.
	///
	/// This is intended to be used with `HBLinkTableCell`.
	///
	/// @see `HBLinkTableCell`
	@objc(hb_openURL:)
	func openURL(specifier: PSSpecifier?) {
		guard let url = (specifier?.properties?["url"] as? URLConvertible)?.url else {
			return
		}

		UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { success in
			if !success {
				self.openURLInBrowser(url)
			}
		}
	}

	private func openURLInBrowser(_ url: URL) {
		if url.scheme == "http" || url.scheme == "https" {
			let viewController = SFSafariViewController(url: url)
			if UIDevice.current.userInterfaceIdiom == .pad {
				viewController.modalPresentationStyle = .formSheet
			}
			viewController.preferredControlTintColor = appearanceSettings?.navigationBarTintColor ?? view.tintColor
			viewController.preferredBarTintColor = appearanceSettings?.navigationBarBackgroundColor
			realNavigationController?.present(viewController, animated: true)
		} else {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	private func promptOpenURLChoices(title: String?, message: String?, choices: [URL], fallbackURL: URL? = nil) {
		var urls = choices
		if let fallbackURL = fallbackURL {
			urls.append(fallbackURL)
		}

		let apps = urls.map { LSApplicationWorkspace.default().applicationsAvailable(forOpening: $0).first }
		let usableApps = apps.filter { $0 != nil }
		if usableApps.isEmpty {
			return
		}

		if usableApps.count == 1 {
			let index = apps.firstIndex(of: usableApps.first!)!
			openURLInBrowser(urls[index])
			return
		}

		let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		for (url, app) in zip(urls, apps) {
			guard let app = app else {
				continue
			}

			let action = UIAlertAction(title: app.localizedName, style: .default) { _ in self.openURLInBrowser(url) }
			if let icon = UIImage._applicationIconImage(forBundleIdentifier: app.bundleIdentifier, format: .small, scale: view.window?.screen.scale ?? 1) {
				action.setValue(icon.withRenderingMode(.alwaysOriginal), forKey: "image")
			}
			alertController.addAction(action)
		}
		alertController.addAction(UIAlertAction(title: .cancel, style: .cancel, handler: nil))
		realNavigationController?.present(alertController, animated: true)
	}

	// MARK: - Package cell

	/// Specifier action to open the package specified by the specifier.
	///
	/// This is intended to be used with `HBPackageTableCell`.
	///
	/// @see `HBPackageTableCell`
	@objc(hb_openPackage:)
	func openPackage(specifier: PSSpecifier?) {
		guard let packageID = specifier?.properties?["packageIdentifier"] as? String,
					let escapedPackageID = packageID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			return
		}

		let repo = specifier?.properties?["packageRepository"] as? String

		var zebraURL = URLComponents(string: "zbra://package/\(escapedPackageID)")!
		if let repo = repo {
			zebraURL.queryItems = [URLQueryItem(name: "source", value: repo)]
		}

		let choices = [
			URL(string: "sileo://package/\(escapedPackageID)")!,
			zebraURL.url!
		]

		promptOpenURLChoices(title: .localize("OPEN_PACKAGE_IN_TITLE", tableName: "PackageCell"),
												 message: repo == nil ? nil : String(format: .localize("OPEN_PACKAGE_IN_REPO_NOTICE", tableName: "PackageCell"), repo!),
												 choices: choices)
	}

	// MARK: - Mastodon cell

	/// Specifier action to open the Mastodon account specified by the specifier.
	///
	/// This is intended to be used with `HBMastodonTableCell`.
	///
	/// @see `HBMastodonTableCell`

	@objc(hb_openMastodon:)
	func openMastodon(specifier: PSSpecifier?) {
		guard let account = specifier?.properties?["account"] as? String,
					let url = (specifier?.properties?["url"] as? URLConvertible)?.url,
					let (user, host) = MastodonAPIClient.parseAccount(from: account) else {
			return
		}

		let choices = [
			URL(string: "ivory:///user_profile/\(user)@\(host)")!,
			URL(string: "icecubesapp://\(host)/@\(user)")!,
			URL(string: "mammoth://\(host)/@\(user)")!,
			URL(string: "tusker://\(host)/@\(user)")!,
			URL(string: "cx-c3-toot://\(host)/@\(user)")!,
			URL(string: "mastodon://profile/@\(user)@\(host)")!
		]
		promptOpenURLChoices(title: nil, message: nil, choices: choices, fallbackURL: url)
	}

}
