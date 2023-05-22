
/// The HBSpinnerTableCell class in CepheiPrefs displays an activity indicator when the cell is
/// disabled.
///
/// ### Example Usage
/// Specifier plist:
///
/// ```xml
/// <dict>
/// 	<key>action</key>
/// 	<string>doStuffTapped:</string>
/// 	<key>cell</key>
/// 	<string>PSButtonCell</string>
/// 	<key>cellClass</key>
/// 	<string>HBSpinnerTableCell</string>
/// 	<key>label</key>
/// 	<string>Do Stuff</string>
/// </dict>
/// ```
///
/// List controller implementation:
///
/// ```swift
/// @objc func doStuffTapped(_ specifier: PSSpecifier) {
/// 	guard let cell = cachedCell(for: specifier) else {
/// 		return
/// 	}
///
/// 	cell.cellEnabled = false
/// 	// Do something in the background…
/// 	cell.cellEnabled = true
/// }
/// ```
///
/// ```objc
/// - (void)doStuffTapped:(PSSpecifier *)specifier {
/// 	PSTableCell *cell = [self cachedCellForSpecifier:specifier];
/// 	cell.cellEnabled = NO;
/// 	// Do something in the background…
/// 	cell.cellEnabled = YES;
/// }
/// ```

@objc(HBSpinnerTableCell)
class SpinnerTableCell: HBTintedTableCell {

	private let spinner = UIActivityIndicatorView(style: .medium)

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, specifier: PSSpecifier?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier, specifier: specifier)
		accessoryView = spinner
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		accessoryView = spinner
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var cellEnabled: Bool {
		didSet {
			if cellEnabled {
				spinner.stopAnimating()
			} else {
				spinner.startAnimating()
			}
		}
	}

}
