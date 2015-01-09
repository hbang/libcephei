#import <Preferences/PSTableCell.h>

/**
 * The `HBTwitterCell` class in `libcepheiprefs` displays a button containing a
 * person's name, along with their Twitter username and avatar. When tapped,
 * a Twitter client installed on the user's device or the Twitter website is
 * opened to the person's profile.
 *
 * ### Specifier Parameters
 * <table>
 * <tr>
 * <th>big</th> <td>Whether to display the username below the name (true) or
 * to the right of it (false). The default is false. If you set this to true,
 * you should also set the cell's height to 56pt.</td>
 * </tr>
 * <tr>
 * <th>label</th> <td>The name of the person.</td>
 * </tr>
 * <tr>
 * <th>showAvatar</th> <td>Whether to show the avatar of the user. The default
 * is true.</td>
 * </tr>
 * <tr>
 * <th>user</th> <td>The Twitter username of the person.</td>
 * </tr>
 * </table>
 *
 * ### Example Usage:
 * 	<!-- Standard size: -->
 * 	<dict>
 * 		<key>cellClass</key>
 * 		<string>HBTwitterCell</string>
 * 		<key>label</key>
 * 		<string>HASHBANG Productions</string>
 * 		<key>user</key>
 * 		<string>hbangws</string>
 * 	</dict>
 *
 * 	<!-- Big size: -->
 * 	<dict>
 * 		<key>big</key>
 * 		<true/>
 * 		<key>cellClass</key>
 * 		<string>HBTwitterCell</string>
 * 		<key>height</key>
 * 		<integer>56</integer>
 * 		<key>label</key>
 * 		<string>HASHBANG Productions</string>
 * 		<key>user</key>
 * 		<string>hbangws</string>
 * 	</dict>
 *
 * 	<!-- Without an avatar: -->
 * 	<dict>
 * 		<key>cellClass</key>
 * 		<string>HBTwitterCell</string>
 * 		<key>label</key>
 * 		<string>HASHBANG Productions</string>
 * 		<key>showAvatar</key>
 * 		<false/>
 * 		<key>user</key>
 * 		<string>hbangws</string>
 * 	</dict>
 */

@interface HBTwitterCell : PSTableCell

@end
