#import "../HBPreferences.h"

void usage() {
	printf(
		"defaults: read and write preferences using Cephei\n"
		"\n"
		"Usage:\n"
		"  defaults read <id>                 Show all preferences for id.\n"
		"  defaults read <id> <key>           Show value for preference key in id.\n"
		"  defaults write <id> <key> <value>  Write value for preference key in id.\n"
		"  defaults help                      Display this help.\n"
		"\n"
		"Value is one of:\n"
		"  <value> | -string <value>          String\n"
		"  -int[eger] <value>                 Integer\n"
		"  -float <value>                     Float\n"
		"  -bool[ean] <value>                 Boolean\n"
		"\n"
		"  Values not matching the specified type will be converted to an equivalent\n"
		"  value in that type. Dictionary, array, data, and date values are not\n"
		"  currently supported for writing through this tool.\n" // TODO: <-- support these types
		"\n"
		"Returns:\n"
		"  0 on success. 1 on failure to read/write. 255 on invalid input.\n"
		"\n"
		"Examples:\n"
		"  defaults read com.apple.springboard\n"
		"  defaults read com.apple.springboard SBBacklightLevel2\n"
		"  defaults write -g AppleLocale en_US\n"
		"  defaults write com.apple.springboard SBBacklightLevel2 -float 0.5\n");
}

int main(int argc, char *argv[]) {
	NSArray <NSString *> *arguments = [NSProcessInfo processInfo].arguments;

	if (arguments.count < 3) {
		usage();
		return 0;
	}

	NSString *identifier = arguments[2];

	if ([identifier isEqualToString:@"-globalDomain"] || [identifier isEqualToString:@"-g"]) {
		identifier = @".GlobalPreferences";
	}

	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:identifier];
	NSString *mode = arguments[1];

	if ([mode isEqualToString:@"read"]) {
		NSObject *value = arguments.count < 4 ? preferences.dictionaryRepresentation : preferences[arguments[3]];

		if (value) {
			printf("%s\n", value.description.UTF8String);
			return 0;
		} else {
			return 1;
		}
	} else if ([mode isEqualToString:@"write"] && (arguments.count == 5 || arguments.count == 6)) {
		NSString *key = arguments[3];
		NSString *type = arguments.count == 5 ? @"-string" : arguments[4];
		NSString *value = arguments.count == 5 ? arguments[4] : arguments[5];

		// TODO: support date? arrays/dictionaries?!
		if ([type isEqualToString:@"-int"] || [type isEqualToString:@"-integer"]) {
			[preferences setInteger:value.integerValue forKey:key];
		} else if ([type isEqualToString:@"-float"]) {
			[preferences setFloat:value.floatValue forKey:key];
		} else if ([type isEqualToString:@"-bool"] || [type isEqualToString:@"-boolean"]) {
			[preferences setBool:value.boolValue forKey:key];
		} else if ([type isEqualToString:@"-string"]) {
			[preferences setObject:value forKey:key];
		} else {
			printf("Unrecognized type \"%s\". For help, use \"defaults --help\".\n", type.UTF8String);
			return 255;
		}

		// synchronize is usually bad™, but necessary when the process is about to exit as the messages
		// may not have reached cfprefsd yet. it’ll spin until cfprefsd has acknowledged the write
		return [preferences synchronize] ? 0 : 1;
	} else if ([mode isEqualToString:@"help"] || [mode isEqualToString:@"--help"]) {
		usage();
		return 0;
	} else {
		printf("Unrecognized mode \"%s\". For help, use \"defaults --help\".\n", mode.UTF8String);
		return 255;
	}
}
