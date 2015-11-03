#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#pragma mark - Fallback

%hook NSBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
	NSString *string = %orig;

	if ((!string || [string isEqualToString:key] || [string isEqualToString:value]) && [self.bundleURL.pathComponents containsObject:@"PreferenceBundles"] && self != globalBundle) {
		string = [globalBundle localizedStringForKey:key value:value table:tableName];

		if (!string || [string isEqualToString:key] || [string isEqualToString:value]) {
			string = [globalBundle localizedStringForKey:key value:value table:@"Common"];
		}
	}

	return string;
}

%end

#pragma mark - Localize specifier keys

%hook PSListController

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(PSListController *)target {
	NSArray *specifiers = %orig;
	NSBundle *bundle = [NSBundle bundleForClass:self.class];

	for (PSSpecifier *specifier in specifiers) {
		if (specifier.properties[@"singularLabel"]) {
			specifier.properties[@"singularLabel"] = [bundle localizedStringForKey:specifier.properties[@"singularLabel"] value:@"" table:plistName];
		}
	}

	return specifiers;
}

%end
