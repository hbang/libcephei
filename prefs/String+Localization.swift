import UIKit

extension String {
	private static let cepheiBundle = Bundle(identifier: "ws.hbang.common.prefs")!
	private static let uikitBundle  = Bundle(for: UIView.self)

	static func localize(_ key: String, bundle: Bundle = cepheiBundle, tableName: String? = nil, comment: String = "") -> String {
		NSLocalizedString(key, tableName: tableName, bundle: bundle, comment: comment)
	}

	static var ok: String     { .localize("OK",       bundle: uikitBundle) }
	static var cancel: String { .localize("Cancel",   bundle: uikitBundle) }
}
