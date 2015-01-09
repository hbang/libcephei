#import "HBOutputForShellCommand.h"

NSString *HBOutputForShellCommandWithReturnCode(NSString *command, int *returnCode) {
	FILE *file = popen(command.UTF8String, "r");

	if (!file) {
		return nil;
	}

	char data[1024];
	NSMutableString *output = [NSMutableString string];

	while (fgets(data, 1024, file) != NULL) {
		[output appendString:[NSString stringWithUTF8String:data]];
	}

	int result = pclose(file);
	*returnCode = result;

	return [NSString stringWithString:output];
}
