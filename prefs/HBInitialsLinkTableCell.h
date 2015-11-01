#import <Preferences/PSTableCell.h>

/**
 * The `HBInitialsLinkTableCell` class in `CepheiPrefs` displays a button that,
 * when tapped, opens the specified URL. A typical icon can be used, or the
 * initials key can be set to one or two characters to show as the icon.
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
 */

@interface HBInitialsLinkTableCell : PSTableCell

@end
