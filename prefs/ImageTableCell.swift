import UIKit
import Preferences

/// The HBImageTableCell class in CepheiPrefs provides a simple way to display an image as a
/// table cell, or a header or footer.
///
/// ### Specifier Parameters
/// <table class="graybox">
/// <tr>
/// <td>icon</td> <td>Required. The file name of the image to display in the cell.</td>
/// </tr>
/// </table>
///
/// If you use `HBImageTableCell` as a header or footer with `headerCellClass` or `footerCellClass`,
/// it will size automatically to fit the image. If you use it as a cell with `cellClass`, you must
/// set the height yourself using the `height` key.
///
/// ### Example Usage
/// ```xml
/// <!-- As a header (or footer): -->
/// <dict>
/// 	<key>cell</key>
/// 	<string>PSGroupCell</string>
/// 	<key>headerCellClass</key>
/// 	<string>HBImageTableCell</string>
/// 	<key>height</key>
/// 	<integer>100</integer>
/// 	<key>icon</key>
/// 	<string>logo.png</string>
/// </dict>
///
/// <!-- As a cell: -->
/// <dict>
/// 	<key>cellClass</key>
/// 	<string>HBImageTableCell</string>
/// 	<key>height</key>
/// 	<integer>100</integer>
/// 	<key>icon</key>
/// 	<string>logo.png</string>
/// </dict>
/// ```

@objc(HBImageTableCell)
class ImageTableCell: PSTableCell {

	private let bigImageView = UIImageView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, specifier: PSSpecifier?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier, specifier: specifier)
		setUp()
	}

	required init(specifier: PSSpecifier?) {
		super.init(style: .default, reuseIdentifier: "", specifier: specifier)
		setUp()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setUp() {
		backgroundColor = .clear
		backgroundView = nil

		imageView?.isHidden = true
		textLabel?.isHidden = true
		detailTextLabel?.isHidden = true

		if let image = specifier?.properties["iconImage"] as? UIImage {
			bigImageView.image = image
		}

		bigImageView.bounds = contentView.bounds
		bigImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		bigImageView.contentMode = .scaleAspectFit
		bigImageView.layer.minificationFilter = .trilinear
		contentView.addSubview(bigImageView)
	}

	override func refreshCellContents(with specifier: PSSpecifier) {
		super.refreshCellContents(with: specifier)

		if let image = specifier.properties["iconImage"] as? UIImage {
			bigImageView.image = image
		}
	}

}

extension ImageTableCell: PSHeaderFooterView {
	func preferredHeight(forWidth width: CGFloat) -> CGFloat {
		guard let image = bigImageView.image else {
			return 0
		}

		return width * (image.size.height / image.size.width)
	}
}
