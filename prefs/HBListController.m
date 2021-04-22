#import "HBListController.h"
#import "HBListController+Actions.h"
#import "HBListController+Deprecated.h"
#import "HBAppearanceSettings.h"
#import "HBLinkTableCell.h"
#import "HBPackageTableCell.h"
#import "HBTwitterCell.h"
#import "HBTwitterAPIClient.h"
#import "PSListController+HBTintAdditions.h"
#import "UINavigationItem+HBTintAdditions.h"
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

- (UIImageSymbolWeight)symbolWeightWithString:(NSString *)weight {
	if ([weight isEqualToString:@"UIImageSymbolWeightUltraLight"] || [weight isEqualToString:@"ultraLight"]) {
		return UIImageSymbolWeightUltraLight;
	}
	if ([weight isEqualToString:@"UIImageSymbolWeightThin"] || [weight isEqualToString:@"thin"]) {
		return UIImageSymbolWeightThin;
	}
	if ([weight isEqualToString:@"UIImageSymbolWeightLight"] || [weight isEqualToString:@"light"]) {
		return UIImageSymbolWeightLight;
	}
	if ([weight isEqualToString:@"UIImageSymbolWeightMedium"] || [weight isEqualToString:@"medium"]) {
		return UIImageSymbolWeightMedium;
	}
	if ([weight isEqualToString:@"UIImageSymbolWeightSemibold"] || [weight isEqualToString:@"semiBold"]) {
		return UIImageSymbolWeightSemibold;
	}
	if ([weight isEqualToString:@"UIImageSymbolWeightBold"] || [weight isEqualToString:@"bold"]) {
		return UIImageSymbolWeightBold;
	}
	if ([weight isEqualToString:@"UIImageSymbolWeightHeavy"] || [weight isEqualToString:@"heavy"]) {
		return UIImageSymbolWeightHeavy;
	}
	if ([weight isEqualToString:@"UIImageSymbolWeightBlack"] || [weight isEqualToString:@"black"]) {
		return UIImageSymbolWeightBlack;
	}
	return UIImageSymbolWeightRegular;
}

- (UIImageSymbolScale)symbolScaleWithString:(NSString *)scale {
	if ([scale isEqualToString:@"UIImageSymbolScaleSmall"] || [scale isEqualToString:@"small"]) {
		return UIImageSymbolScaleSmall;
	}
	if ([scale isEqualToString:@"UIImageSymbolScaleMedium"] || [scale isEqualToString:@"medium"]) {
		return UIImageSymbolScaleMedium;
	}
	if ([scale isEqualToString:@"UIImageSymbolScaleLarge"] || [scale isEqualToString:@"large"]) {
		return UIImageSymbolScaleLarge;
	}
	return UIImageSymbolWeightRegular;
}

- (UIImage *)imageSystemFromDict:(NSDictionary *)imageSystem {
	UIImageSymbolWeight weight = UIImageSymbolWeightRegular;
	id weightValue = iconImageSystem[@"weight"];
	if ([weightValue isKindOfClass:NSString.class]) {
		weight = [self symbolWeightWithString:weightValue];
	} else if ([weightValue isKindOfClass:NSNumber.class]) {
		weight = [weightValue integerValue];
	}

	UIImageSymbolScale scale = UIImageSymbolScaleMedium;
	id scaleValue = iconImageSystem[@"scale"];
	if ([scaleValue isKindOfClass:NSString.class]) {
		scale = [self symbolScaleWithString:scaleValue];
	} else if ([scaleValue isKindOfClass:NSNumber.class]) {
		scale = [scaleValue integerValue];
	}

	UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration
		configurationWithPointSize:([imageSystem[@"pointSize"] floatValue] ?: 20.0)
		weight:weight
		scale:scale
	];

	return [UIImage systemImageNamed:imageSystem[@"name"] withConfiguration:configuration];
}

- (NSMutableArray *)_hb_configureSpecifiers:(NSMutableArray *)specifiers {
	NSMutableArray *specifiersToRemove = [NSMutableArray array];
	NSMutableArray <NSString *> *twitterUsernames = [NSMutableArray array];
	NSMutableArray <NSString *> *twitterUserIDs = [NSMutableArray array];

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

		// grab the cell class
		Class cellClass = specifier.properties[PSCellClassKey];

		// if it’s HBLinkTableCell, override the type and action to our own
		if ([cellClass isSubclassOfClass:HBLinkTableCell.class] && specifier.buttonAction == nil) {
			specifier.cellType = PSLinkCell;
			if ([cellClass isSubclassOfClass:HBPackageTableCell.class]) {
				specifier.buttonAction = @selector(hb_openPackage:);
			} else {
				specifier.buttonAction = @selector(hb_openURL:);
			}
			if ([cellClass isSubclassOfClass:HBTwitterCell.class]) {
				if (specifier.properties[@"userID"] != nil) {
					[twitterUserIDs addObject:specifier.properties[@"userID"]];
				} else if (specifier.properties[@"user"] != nil) {
					[twitterUsernames addObject:specifier.properties[@"user"]];
				}
			}
			if (!IS_IOS_OR_NEWER(iOS_8_0)) {
				specifier.controllerLoadAction = specifier.buttonAction;
			}
		}

		// allow SF Symbols to be used in .plist
		// [specifier setProperty:[self imageSystemFromDict:specifier.properties[@"iconImageSystem"]] forKey:@"iconImage"];
		// [specifier setProperty:[self imageSystemFromDict:specifier.properties[@"leftImageSystem"]] forKey:@"leftImage"];
		// [specifier setProperty:[self imageSystemFromDict:specifier.properties[@"rightImageSystem"]] forKey:@"rightImage"];
		specifier.properties[@"iconImage"] = [self imageSystemFromDict:specifier.properties[@"iconImageSystem"];
		specifier.properties[@"leftImage"] = [self imageSystemFromDict:specifier.properties[@"leftImageSystem"];
		specifier.properties[@"rightImage"] = [self imageSystemFromDict:specifier.properties[@"rightImageSystem"];
	}

	// if we have specifiers to remove
	if (specifiersToRemove.count > 0) {
		// make a mutable copy of the specifiers
		NSMutableArray *newSpecifiers = [specifiers mutableCopy];

		// remove all the filtered specifiers
		[newSpecifiers removeObjectsInArray:specifiersToRemove];

		// and assign it to specifiers again
		specifiers = newSpecifiers;
	}

	if (twitterUsernames.count > 0 || twitterUserIDs.count > 0) {
		// Queue up all Twitter usernames/user IDs at once so we can bulk load them for performance.
		[[HBTwitterAPIClient sharedInstance] queueLookupsForUsernames:twitterUsernames userIDs:twitterUserIDs];
	}

	return specifiers;
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
	// fixes weird iOS 7 glitch, a little neater than before, and ideally preventing
	// crashes on iPads and older devices.
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
