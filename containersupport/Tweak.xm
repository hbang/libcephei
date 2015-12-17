#import <installd/MIExecutableBundle.h>

static NSString *const kHBAppRequiresContainer = @"HBAppRequiresContainer";

%hook MIInstalledInfoGatherer

+ (NSSet *)infoPlistKeysToLoad {
	return [%orig setByAddingObject:kHBAppRequiresContainer];
}

%end

%hook MIExecutableBundle

- (BOOL)needsDataContainer {
	if (self.bundleType == MIBundleTypeSystemApp) {
		NSNumber *useContainer = self.infoPlistSubset[kHBAppRequiresContainer];

		if (useContainer && useContainer.boolValue) {
			return YES;
		}
	}

	return %orig;
}

%end
