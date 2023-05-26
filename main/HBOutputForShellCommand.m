#import "HBOutputForShellCommand.h"
#import "Cephei-Swift.h"

NSString *HBOutputForShellCommandWithReturnCode(NSString *command, int *returnCode) {
	int status = 0;
	NSString *result = [HBCommand executeSync:@INSTALL_PREFIX @"/bin/sh" arguments:@[@"-c", command] status:&status];
	if (returnCode) {
		*returnCode = status;
	}
	return result;
}

NSString *HBOutputForShellCommand(NSString *command) {
	int returnCode = 0;
	NSString *output = HBOutputForShellCommandWithReturnCode(command, &returnCode);
	return returnCode == 0 ? output : nil;
}
