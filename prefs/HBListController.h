#import <Preferences/PSListController.h>
#import "PSListController+HBTintAdditions.h"

NS_ASSUME_NONNULL_BEGIN

/// The HBListController class in CepheiPrefs provides a list controller with various
/// conveniences such as a unique tint color for the list controllers within a preference bundle,
/// and bug fixes for common issues within the Settings app and Preferences framework. In
/// particular, a bug with the list controller’s content disappearing after closing the Settings
/// app and opening it again is worked around, as well as an issue on iOS 7 where in some cases a
/// cell may stay highlighted after being tapped.
///
/// It includes two class methods you can override to return the name of a Preferences specifier
/// property list, and various methods to control appearance of the interface.
///
/// If you use HBLinkTableCell or subclasses such as HBTwitterCell and HBPackageTableCell, it is
/// recommended to subclass from HBListController on the view controller classes containing these
/// cells to use CepheiPrefs’s built-in callback actions. If you do not subclass from
/// HBListController, you will need to implement action methods yourself.

@interface HBListController : PSListController

/// @name Specifiers

/// The property list that contains Preference framework specifiers to display as the content of the
/// list controller. Override this method to return the file name of a property list inside your
/// preference bundle, omitting the file extension.
///
/// Example:
/// ```objc
/// + (NSString *)hb_specifierPlist {
/// 	return @"Root";
/// }
/// ```
///
/// If you use this method and override the `specifiers` method, ensure you call the super method
/// with `[super specifiers];` first in your `specifiers` implementation.
///
/// @return By default, nil.
@property (nonatomic, strong, readonly, class, nullable) NSString *hb_specifierPlist NS_SWIFT_NAME(specifierPlist);

/// @name Related View Controllers

/// Returns the “real” navigation controller for this view controller.
///
/// As of iOS 8.0, the navigation controller that owns the navigation bar and other responsibilities
/// is actually a parent of `self.navigationController` on iPhone, due to the larger Plus models.
/// The realNavigationController method returns the correct navigation controller.
///
/// @return The real navigation controller.
- (UINavigationController *)realNavigationController;

@end

NS_ASSUME_NONNULL_END
