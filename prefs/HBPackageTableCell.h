#import <Preferences/PSTableCell.h>

/**
 * The `HBPackageTableCell` class in `CepheiPrefs` provides a cell containing
 * any package's icon, name, and description. Tapping it opens the package in
 * in Cydia.
 *
 * ### Specifier Parameters
 * <table>
 * <tr>
 * <th>packageIdentifier</th> <td>Required. The package identifier to retrieve
 * the required information from.</td>
 * </tr>
 * <tr>
 * <th>packageRepository</th> <td>Optional. The URL to the repository the
 * package is available on, if not one of the default repos.</td>
 * </tr>
 * <tr>
 * <th>label</th> <td>Required. The name of the package.</td>
 * </tr>
 * <tr>
 * <th>subtitleText</th> <td>Optional. Can be used for a description of the
 * package.</td>
 * </tr>
 * </tr>
 * </table>
 *
 * ### Example Usage
 * 	<!-- Standard: -->
 * 	<dict>
 * 		<key>cell</key>
 * 		<string>PSGroupCell</string>
 * 		<key>headerCellClass</key>
 * 		<string>HBPackageNameHeaderCell</string>
 * 		<key>packageIdentifier</key>
 * 		<string>ws.hbang.common</string>
 * 	</dict>
 *
 * 	<!-- Condensed size: -->
 * 	<dict>
 * 		<key>cell</key>
 * 		<string>PSGroupCell</string>
 * 		<key>condensed</key>
 * 		<true/>
 * 		<key>headerCellClass</key>
 * 		<string>HBPackageNameHeaderCell</string>
 * 		<key>icon</key>
 * 		<string>icon.png</string>
 * 		<key>packageIdentifier</key>
 * 		<string>ws.hbang.common</string>
 * 	</dict>
 *
 * 	<!-- Standard size with custom colors: -->
 * 	<dict>
 * 		<key>cell</key>
 * 		<string>PSGroupCell</string>
 * 		<key>headerCellClass</key>
 * 		<string>HBPackageNameHeaderCell</string>
 * 		<key>packageIdentifier</key>
 * 		<string>ws.hbang.common</string>
 * 		<key>titleColor</key>
 * 		<string>#CC0000</string>
 * 		<key>subtitleColor</key>
 * 		<array>
 * 			<integer>55</integer>
 * 			<integer>147</integer>
 * 			<integer>230</integer>
 * 		</array>
 * 	</dict>
 *
 * 	<!-- Standard size with gradient background: -->
 * 	<dict>
 * 		<key>cell</key>
 * 		<string>PSGroupCell</string>
 * 		<key>headerCellClass</key>
 * 		<string>HBPackageNameHeaderCell</string>
 * 		<key>packageIdentifier</key>
 * 		<string>ws.hbang.common</string>
 * 		<key>backgroundGradientColors</key>
 * 		<array>
 * 			<string>#5AD427</string>
 * 			<string>#FFDB4C</string>
 * 			<string>#EF4DB6</string>
 * 			<string>#898C90</string>
 * 		</array>
 * 	</dict>
 */
@interface HBPackageTableCell : PSTableCell

@end
