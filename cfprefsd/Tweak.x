@import Foundation;
@import os.log;
#import <libgen.h>
#import <sandbox.h>
#import "../main/HBPreferencesCommon.h"

// <libbsm.h>
extern pid_t audit_token_to_pid(audit_token_t token);

%hookf(int, sandbox_check_by_audit_token, audit_token_t auditToken, const char *operation, enum sandbox_filter_type type, ...) {
	va_list args;
	va_start(args, type);
	const char *domain = va_arg(args, const char *);
	const void *arg2   = va_arg(args, void *);
	const void *arg3   = va_arg(args, void *);
	const void *arg4   = va_arg(args, void *);
	const void *arg5   = va_arg(args, void *);
	const void *arg6   = va_arg(args, void *);
	const void *arg7   = va_arg(args, void *);
	const void *arg8   = va_arg(args, void *);
	const void *arg9   = va_arg(args, void *);
	const void *arg10  = va_arg(args, void *);
	va_end(args);

	if (
		domain != NULL && operation != NULL &&
		(type & SANDBOX_FILTER_PREFERENCE_DOMAIN) == SANDBOX_FILTER_PREFERENCE_DOMAIN &&
		(strcmp(operation, "user-preference-read") == 0 || strcmp(operation, "user-preference-write") == 0) &&
		strcmp(domain, [(__bridge NSString *)kCFPreferencesAnyApplication UTF8String]) != 0 &&
		isIdentifierPermitted([NSString stringWithUTF8String:domain])
	) {
		int realResult = %orig(auditToken, operation, type | SANDBOX_CHECK_NO_REPORT, domain, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
		if (realResult != 0) {
			// Log for debugging purposes that we’re allowing something that was supposed to be denied
			pid_t pid = audit_token_to_pid(auditToken);
			os_log(OS_LOG_DEFAULT, "Allowing %{public}s for identifier %{public}s in pid %{public}i", operation, domain, pid);
		}
		return 0;
	}

	return %orig(auditToken, operation, type, domain, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
}
