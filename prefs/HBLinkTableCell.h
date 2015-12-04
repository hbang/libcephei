#import <Preferences/PSTableCell.h>

/**
 * The `HBLinkTableCell` class in `CepheiPrefs` displays a button that, when
 * tapped, opens the specified URL. A typical icon can be used, or the initials
 * key can be set to one or two characters to show as the icon.
 *
 * This cell can either be used without setting any cell type, or by setting it
 * to `PSButtonCell` to get a tinted button.
 *
 * Requires iOS 7.0 or later.
 *
 * ### Specifier Parameters
 * <table>
 * <tr>
 * <th>initials</th> <td>Optional. One or two characters to show as the
 * icon.</td>
 * </tr>
 * <tr>
 * <th>url</th> <td>Required. The URL to open.</td>
 * </tr>
 * <tr>
 * <th>subtitle</th> <td>Optional. A subtitle to display below the label. The
 * default is an empty string, hiding the subtitle.</td>
 * </tr>
 * </table>
 *
 * ### Example Usage
 * 	<!-- With icon: -->
 * 	<dict>
 * 		<key>cellClass</key>
 * 		<string>HBInitialsLinkTableCell</string>
 * 		<key>icon</key>
 * 		<string>example.png</string>
 * 		<key>label</key>
 * 		<string>Example</string>
 * 		<key>url</key>
 * 		<string>http://example.com/</string>
 * 	</dict>
 *
 * 	<!-- With initials: -->
 * 	<dict>
 * 		<key>cellClass</key>
 * 		<string>HBInitialsLinkTableCell</string>
 * 		<key>initials</key>
 * 		<string>XX</string>
 * 		<key>label</key>
 * 		<string>Example</string>
 * 		<key>url</key>
 * 		<string>http://example.com/</string>
 * 	</dict>
 *
 * 	<!-- With a subtitle, styled as a button: -->
 * 	<dict>
 * 		<key>cell</key>
 * 		<string>PSButtonCell</string>
 * 		<key>cellClass</key>
 * 		<string>HBInitialsLinkTableCell</string>
 * 		<key>label</key>
 * 		<string>Example</string>
 * 		<key>subtitle</key>
 * 		<string>Visit our amazing website</string>
 * 		<key>url</key>
 * 		<string>http://example.com/</string>
 * 	</dict>
 */

@interface HBLinkTableCell : PSTableCell

@end
