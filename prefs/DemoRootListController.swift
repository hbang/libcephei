import UIKit
import CepheiUI

/// The HBDemoRootListController class in CepheiPrefs provides a demo of a preference page
/// created using `HBRootListController`. See the Cephei readme for details.

@objc(HBDemoRootListController)
class DemoRootListController: RootListController {

	override var specifierPlist: String? { "DemoRoot" }

	override var shareText: String? { "Cephei is a great developer library used behind the scenes of jailbroken iOS packages." }
	override var shareURL: URL? { URL(string: "https://hbang.github.io/libcephei/") }

	override func viewDidLoad() {
		super.viewDidLoad()

		let appearanceSettings = AppearanceSettings()
		appearanceSettings.tintColor = .systemPurple.withDarkInterfaceVariant(.systemPink)
		appearanceSettings.userInterfaceStyle = .dark
		appearanceSettings.navigationBarTintColor = .systemCyan
		appearanceSettings.navigationBarBackgroundColor = .systemPurple
		appearanceSettings.navigationBarTitleColor = .white
		appearanceSettings.statusBarStyle = .lightContent
		appearanceSettings.showsNavigationBarShadow = false
		appearanceSettings.largeTitleStyle = .always
		appearanceSettings.tableViewCellTextColor = .white
		appearanceSettings.tableViewCellBackgroundColor = .init(white: 22 / 255, alpha: 1)
		appearanceSettings.tableViewCellSeparatorColor = .init(white: 38 / 255, alpha: 1)
		appearanceSettings.tableViewCellSelectionColor = .init(white: 46 / 255, alpha: 1)
		appearanceSettings.tableViewBackgroundColor = .init(white: 44 / 255, alpha: 1)
		self.appearanceSettings = appearanceSettings
	}

	@objc func doStuffTapped(_ specifier: PSSpecifier?) {
		guard let specifier = specifier,
					let cell = cachedCell(for: specifier) else {
			return
		}

		cell.cellEnabled = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			cell.cellEnabled = true
		}
	}

}
