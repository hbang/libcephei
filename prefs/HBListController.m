#import "HBListController.h"
#import "HBListController+Actions.h"
#import "HBListController+Deprecated.h"
#import "HBAppearanceSettings.h"
#import "HBLinkTableCell.h"
#import "HBPackageTableCell.h"
#import "PSListController+HBTintAdditions.h"
#import "UINavigationItem+HBTintAdditions.h"
#import "Symbols.h"
#import <Preferences/PSSpecifier.h>
#import <version.h>

@interface PSListController ()

- (UINavigationController *)_hb_realNavigationController;
- (void)_hb_getAppearance;

@end

@interface HBListController (DeprecatedPrivate)

- (void)_handleDeprecatedAppearanceMethods;

@end

@implementation HBListController {
	NSArray *__deprecatedAppearanceMethodsInUse;
}

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return nil;
}

#pragma mark - Loading specifiers

- (void)_loadSpecifiersFromPlistIfNeeded {
	if (_specifiers || ![self.class hb_specifierPlist]) {
		return;
	}

	_specifiers = [self loadSpecifiersFromPlistName:[self.class hb_specifierPlist] target:self];
}

- (NSArray *)specifiers {
	[self _loadSpecifiersFromPlistIfNeeded];
	return _specifiers;
}

- (NSMutableArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(PSListController *)target {
	// Override the loading mechanism so we can add additional features.
	NSMutableArray *specifiers = [super loadSpecifiersFromPlistName:plistName target:target];
	return [self _hb_configureSpecifiers:specifiers];
}

- (NSMutableArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(PSListController *)target bundle:(NSBundle *)bundle {
	// Override the loading mechanism so we can add additional features.
	NSMutableArray *specifiers = [super loadSpecifiersFromPlistName:plistName target:target bundle:bundle];
	return [self _hb_configureSpecifiers:specifiers];
}

- (NSMutableArray *)_hb_configureSpecifiers:(NSMutableArray *)specifiers {
	NSMutableArray *specifiersToRemove = [NSMutableArray array];

	for (PSSpecifier *specifier in specifiers) {
		// Reimplementation of libprefs (from PreferenceLoader) pl_filter.
		// When there is 1 item in CoreFoundationVersion: This number is the minimum bound.
		// When there are 2 items in CoreFoundationVersion: First item is min bound, second is max bound.
		NSDictionary *filters = specifier.properties[@"pl_filter"];

		if (filters && filters[@"CoreFoundationVersion"]) {
			NSArray <NSNumber *> *versionFilter = filters[@"CoreFoundationVersion"];

			double min = versionFilter[0] ? ((NSNumber *)versionFilter[0]).doubleValue : DBL_MIN;
			double max = versionFilter.count > 1 && versionFilter[1] ? ((NSNumber *)versionFilter[1]).doubleValue : DBL_MAX;

			if (kCFCoreFoundationVersionNumber < min || kCFCoreFoundationVersionNumber >= max) {
				[specifiersToRemove addObject:specifier];
			}
		}

		Class cellClass = specifier.properties[PSCellClassKey];
		if ([cellClass isSubclassOfClass:HBLinkTableCell.class] && (![specifier respondsToSelector:@selector(buttonAction)] || specifier.buttonAction == nil)) {
			// Override the type and action to our own.
			specifier.cellType = PSLinkCell;
			SEL action;
			if ([cellClass isSubclassOfClass:HBPackageTableCell.class]) {
				action = @selector(hb_openPackage:);
			} else {
				action = @selector(hb_openURL:);
			}
			if (IS_IOS_OR_NEWER(iOS_8_0)) {
				specifier.buttonAction = action;
			} else if (IS_IOS_OR_NEWER(iOS_6_0)) {
				specifier.controllerLoadAction = action;
			} else {
				specifier->action = action;
			}
		}

		// Support for SF Symbols (system images)
		if (IS_IOS_OR_NEWER(iOS_13_0)) {
			if (@available(iOS 13, *)) {
				UIImage *iconImage = [self _hb_symbolImageFromDictionary:specifier.properties[@"iconImageSystem"]];
				if (iconImage != nil) {
					specifier.properties[@"iconImage"] = iconImage;
				}

				UIImage *leftImage = [self _hb_symbolImageFromDictionary:specifier.properties[@"leftImageSystem"]];
				if (leftImage != nil) {
					specifier.properties[@"leftImage"] = leftImage;
				}

				UIImage *rightImage = [self _hb_symbolImageFromDictionary:specifier.properties[@"rightImageSystem"]];
				if (rightImage != nil) {
					specifier.properties[@"rightImage"] = rightImage;
				}
			}
		}
	}

	// If we have specifiers to remove, make a mutable copy of the specifiers to remove them.
	if (specifiersToRemove.count > 0) {
		NSMutableArray *newSpecifiers = [specifiers mutableCopy];
		[newSpecifiers removeObjectsInArray:specifiersToRemove];
		specifiers = newSpecifiers;
	}

	return specifiers;
}

- (UIImage *)_hb_symbolImageFromDictionary:(NSDictionary <NSString *, id> *)params {
	if (@available(iOS 13, *)) {
		return systemSymbolImageForDictionary(params);
	}
	return nil;
}

#pragma mark - Appearance

- (void)_hb_getAppearance {
	[super _hb_getAppearance];
	[self _handleDeprecatedAppearanceMethods];
}

#pragma mark - Navigation controller quirks

- (UINavigationController *)realNavigationController {
	return [super _hb_realNavigationController];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Fixes weird iOS 7 glitch, a little neater than before, and ideally preventing
	// crashes on iPads and older devices.
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
