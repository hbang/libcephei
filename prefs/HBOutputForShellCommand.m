NSString *HBOutputForShellCommand(NSString *command) {
	FILE *file = popen(command.UTF8String, "r");

	if (!file) {
		return nil;
	}

	char data[1024];
	NSMutableString *output = [NSMutableString string];

	while (fgets(data, 1024, file) != NULL) {
		[output appendString:[NSString stringWithUTF8String:data]];
	}

	if (pclose(file) != 0) {
		return nil;
	}

	return [NSString stringWithString:output];
}
