#import <Cephei/HBPreferences.h>

void usage() {
	printf("Usage: defaults read com.apple.springboard SBBacklightLevel2\n"
	       "       defaults write com.apple.springboard SBBacklightLevel2 -float 0.5\n");
}

int main(int argc, char *argv[]) {
	NSArray *arguments = [NSProcessInfo processInfo].arguments;

	if (arguments.count < 3) {
		usage();
		return 0;
	}

	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:arguments[2]];
	NSString *mode = arguments[1];

	if ([mode isEqualToString:@"read"]) {
		NSObject *value = arguments.count < 4 ? preferences.dictionaryRepresentation : preferences[arguments[3]];

		if (value) {
			printf("%s\n", value.description.UTF8String);
			return 0;
		} else {
			return 1;
		}
	} else if ([mode isEqualToString:@"write"] && arguments.count == 6) {
		NSString *key = arguments[3];
		NSString *type = arguments[4];
		NSString *value = arguments[5];

		// TODO: support date? arrays/dictionaries?!
		if ([type isEqualToString:@"-int"]) {
			[preferences setInteger:value.integerValue forKey:key];
		} else if ([type isEqualToString:@"-float"]) {
			[preferences setFloat:value.floatValue forKey:key];
		} else if ([type isEqualToString:@"-bool"]) {
			[preferences setBool:value.boolValue forKey:key];
		} else if ([type isEqualToString:@"-string"]) {
			[preferences setObject:value forKey:key];
		}

		// synchronize is usually bad™, but in this case we're about to exit, and
		// that means it might not get to cfprefsd in time. catfish man said it's
		// right to do this, so we're doing it
		return [preferences synchronize] == YES;
	} else {
		usage();
		return 0;
	}
}
