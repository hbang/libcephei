#import <installd/MIExecutableBundle.h>

static NSString *const kHBAppRequiresContainer = @"HBAppRequiresContainer";

%hook MIInstalledInfoGatherer

+ (NSSet *)infoPlistKeysToLoad {
	// for some reason, MIExecutableBundle only has a subset of the info.plist,
	// so we need to add our key to the set of keys that are stored. (to reduce
	// memory usage, maybe? wow, devs still care about memory usage?)
	return [%orig setByAddingObject:kHBAppRequiresContainer];
}

%end

%hook MIExecutableBundle

- (BOOL)needsDataContainer {
	// this should only ever apply to a system app. other types don’t need it
	if (self.bundleType == MIBundleTypeSystemApp) {
		NSNumber *useContainer = self.infoPlistSubset[kHBAppRequiresContainer];

		// only override if the key exists and is YES
		if (useContainer && useContainer.boolValue) {
			return YES;
		}
	}

	return %orig;
}

%end
