#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#pragma mark - Fallback

#define kHBCepheiLocalizationFallbackString @"kHBCepheiLocalizationFallbackString"

%hook NSBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
	// ignore our bundle, system bundles, and bundles not somewhere in a dir named PreferenceBundles
	if (self == globalBundle || [self.bundleURL.pathComponents[0] isEqualToString:@"System"] || ![self.bundleURL.pathComponents containsObject:@"PreferenceBundles"]) {
		return %orig;
	}

	// ask for the string, using our fallback string to detect if the value doesn’t exist
	NSString *string = %orig(key, kHBCepheiLocalizationFallbackString, tableName);

	if ([string isEqualToString:kHBCepheiLocalizationFallbackString]) {
		// try using our bundle and same table name
		string = [globalBundle localizedStringForKey:key value:kHBCepheiLocalizationFallbackString table:tableName];

		if ([string isEqualToString:kHBCepheiLocalizationFallbackString]) {
			// try using our bundle in the Common table
			string = [globalBundle localizedStringForKey:key value:value table:@"Common"];
		}
	}

	// return whatever we got
	return string;
}

%end

#pragma mark - Localize specifier keys

%hook PSListController

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(PSListController *)target {
	static NSArray <NSString *> *PropertiesToLocalize;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PropertiesToLocalize = @[ @"singularLabel", @"subtitle" ];
	});

	NSArray *specifiers = %orig;
	NSBundle *bundle = [NSBundle bundleForClass:self.class];

	for (PSSpecifier *specifier in specifiers) {
		for (NSString *key in PropertiesToLocalize) {
			if (specifier.properties[key]) {
				specifier.properties[key] = [bundle localizedStringForKey:specifier.properties[key] value:@"" table:plistName];
			}
		}
	}

	return specifiers;
}

%end
