#import "HBTintedTableCell.h"

/// The `HBLinkTableCell` class in `CepheiPrefs` displays a button that, when tapped, opens the
/// specified URL. A typical icon can be used, or the initials key can be set to one or two
/// characters to show as the icon.
///
/// This cell can either be used without setting any cell type, or by setting it to `PSButtonCell`
/// to get a tinted button.
///
/// ### Specifier Parameters
/// <table>
/// <tr>
/// <th>initials</th> <td>Optional. One or two characters to show as the icon.</td>
/// </tr>
/// <tr>
/// <th>url</th> <td>Required. The URL to open.</td>
/// </tr>
/// <tr>
/// <th>subtitle</th> <td>Optional. A subtitle to display below the label. The default is an empty
/// string, hiding the subtitle.</td>
/// </tr>
/// <tr>
/// <th>avatarURL</th> <td>Optional. The URL to an avatar to display. The default is no value,
/// hiding the avatar.</td>
/// </tr>
/// <tr>
/// <th>avatarCircular</th> <td>Optional. Whether the avatar should be displayed as a circle. The
/// default is YES when an avatarURL is set, otherwise this property is unused.</td>
/// </tr>
/// </table>
///
/// ### Example Usage
/// ```xml
/// <!-- With icon: -->
/// <dict>
/// 	<key>cellClass</key>
/// 	<string>HBLinkTableCell</string>
/// 	<key>icon</key>
/// 	<string>example.png</string>
/// 	<key>label</key>
/// 	<string>Example</string>
/// 	<key>url</key>
/// 	<string>http://example.com/</string>
/// </dict>
///
/// <!-- With initials: -->
/// <dict>
/// 	<key>cellClass</key>
/// 	<string>HBLinkTableCell</string>
/// 	<key>initials</key>
/// 	<string>XX</string>
/// 	<key>label</key>
/// 	<string>Example</string>
/// 	<key>url</key>
/// 	<string>http://example.com/</string>
/// </dict>
///
/// <!-- With a subtitle: -->
/// <dict>
/// 	<key>cellClass</key>
/// 	<string>HBLinkTableCell</string>
/// 	<key>label</key>
/// 	<string>Example</string>
/// 	<key>subtitle</key>
/// 	<string>Visit our amazing website</string>
/// 	<key>url</key>
/// 	<string>http://example.com/</string>
/// </dict>
///
/// <!-- With a subtitle, in big mode: -->
/// <dict>
/// 	<key>big</key>
/// 	<true/>
/// 	<key>cellClass</key>
/// 	<string>HBLinkTableCell</string>
/// 	<key>height</key>
/// 	<integer>64</integer>
/// 	<key>label</key>
/// 	<string>Example</string>
/// 	<key>subtitle</key>
/// 	<string>Visit our amazing website</string>
/// 	<key>url</key>
/// 	<string>http://example.com/</string>
/// </dict>
/// ```

@interface HBLinkTableCell : HBTintedTableCell

/// Whether the cell is 64 pixels or more in height.
///
/// This is not set automatically; the specifier for the cell must set the `big` property to true
/// (see examples above).
@property (nonatomic, readonly) BOOL isBig;

/// The view containing the avatar image view.
@property (nonatomic, retain, readonly) UIView *avatarView;

/// The avatar image view.
@property (nonatomic, retain, readonly) UIImageView *avatarImageView;

/// The image to display as the avatar, if enabled.
@property (nonatomic, retain) UIImage *avatarImage;

/// A URL to load into avatarImage to display as the avatar, if enabled.
@property (nonatomic, retain) NSURL *avatarURL;

/// Whether the image displays as a circle.
///
/// The default is YES if an avatarURL is set in the specifier, otherwise NO.
@property (nonatomic, readonly) BOOL isAvatarCircular;

/// Display the avatar.
///
/// You don’t need to call this unless subclassing.
- (void)loadAvatarIfNeeded;

@end
