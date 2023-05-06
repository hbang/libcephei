#import "../HBOutputForShellCommand.h"

static inline NSString *shellEscape(NSArray <NSString *> *input) {
	NSMutableArray <NSString *> *result = [NSMutableArray array];
	for (NSString *string in input) {
		[result addObject:[NSString stringWithFormat:@"'%@'",
			[string stringByReplacingOccurrencesOfString:@"'" withString:@"\\'" options:NSRegularExpressionSearch range:NSMakeRange(0, string.length)]]];
	}
	return [result componentsJoinedByString:@" "];
}

static inline NSDictionary <NSString *, NSString *> *getFieldsForPackage(NSString *package, NSArray <NSString *> *fields) {
	NSMutableArray *escapedFields = [NSMutableArray array];
	for (NSString *field in fields) {
		[escapedFields addObject:[NSString stringWithFormat:@"${%@}", field]];
	}
	NSString *format = [escapedFields componentsJoinedByString:@"\n"];
	int status;
	NSString *output = HBOutputForShellCommandWithReturnCode(shellEscape(@[ @INSTALL_PREFIX @"/usr/bin/dpkg-query", @"-Wf", format, package ]), &status);
	if (status == 0) {
		NSArray <NSString *> *lines = [output componentsSeparatedByString:@"\n"];
		if (lines.count == fields.count) {
			NSMutableDictionary *result = [NSMutableDictionary dictionary];
			for (NSUInteger i = 0; i < lines.count; i++) {
				if (![lines[i] isEqualToString:@""]) {
					result[fields[i]] = lines[i];
				}
			}
			return result;
		}
	}
	return nil;
}

static inline NSString *getFieldForPackage(NSString *package, NSString *field) {
	NSDictionary <NSString *, NSString *> *result = getFieldsForPackage(package, @[ field ]);
	return result[field];
}
