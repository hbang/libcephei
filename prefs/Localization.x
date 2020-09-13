#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#pragma mark - Fallback

%hook NSBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
	NSString *string = %orig;

	if (cepheiGlobalBundle != nil) {
		if (string == nil || [string isEqualToString:key] || [string isEqualToString:value]) {
			// Make sure we avoid an infinite loop against ourselves when the fallback doesn’t exist
			if (self != cepheiGlobalBundle || ![tableName isEqualToString:@"Common"]) {
				NSString *newString = [cepheiGlobalBundle localizedStringForKey:key value:value table:@"Common"];
				if (newString != nil && ![newString isEqualToString:key] && ![newString isEqualToString:value]) {
					return newString;
				}
			}
		}
	}

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
