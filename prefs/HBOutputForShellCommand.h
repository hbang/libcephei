/**
 * Executes a shell command and returns its output.
 *
 * @param command The shell command to run.
 * @param returnCode A pointer to an integer that will contain the return code
 * of the command.
 * @returns The output of the provided command.
 */
NSString *HBOutputForShellCommandWithReturnCode(NSString *command, int *returnCode);

/**
 * Executes a shell command and returns its output.
 *
 * @param command The shell command to run.
 * @returns The output of the provided command, or nil if the command returned
 * with a code other than 0.
 */
inline NSString *HBOutputForShellCommand(NSString *command) {
	int returnCode = 0;
	NSString *output = HBOutputForShellCommandWithReturnCode(command, &returnCode);
	return returnCode == 0 ? output : nil;
}
