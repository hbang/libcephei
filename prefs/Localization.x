%hook NSBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
	NSString *string = %orig;

	if ((!string || [string isEqualToString:key] || [string isEqualToString:value]) && [self.bundleURL.pathComponents containsObject:@"PreferenceBundles"] && self != globalBundle) {
		string = [globalBundle localizedStringForKey:key value:value table:tableName];
	}

	return string;
}

%end
