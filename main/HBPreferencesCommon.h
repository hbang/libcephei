static inline BOOL isIdentifierPermitted(NSString *identifier) {
	if ([identifier.pathExtension isEqualToString:@"plist"]) {
		identifier = identifier.stringByDeletingPathExtension;
	}

	if ([identifier hasPrefix:@"systemgroup."] || [identifier hasPrefix:@"group."]) {
		identifier = [identifier substringFromIndex:[identifier rangeOfString:@"."].location + 1];
	}

	// Logic borrowed from https://github.com/opa334/Dopamine/blob/0f38bb02d0232cf31b142378b6711a6439434518/BaseBin/rootlesshooks/cfprefsd.x
	if ([identifier hasPrefix:@"com.apple."] || [identifier containsString:@"/"]) {
		return NO;
	}

	static NSArray <NSString *> *disallowedIdentifiers;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		disallowedIdentifiers = @[
			@".GlobalPreferences",
			@".GlobalPreferences_m",
			@"bluetoothaudiod",
			@"com.google.gmp.measurement.monitor",
			@"com.google.gmp.measurement",
			@"dprivacyd",
			@"kNPProgressTrackerDomain",
			@"languageassetd",
			@"mobile_installation_proxy",
			@"mobile_storage_proxy",
			@"NetworkInterfaces",
			@"nfcd",
			@"osanalyticshelper",
			@"OSThermalStatus",
			@"preferences",
			@"ptpcamerad",
			@"silhouette",
			@"siriknowledged",
			@"splashboardd",
			@"UITextInputContextIdentifiers",
			@"UserEventAgent",
			@"wifid"
		];
	});

	return ![disallowedIdentifiers containsObject:identifier];
}
