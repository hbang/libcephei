#import "HBSupportController.h"
#import "../HBPreferences.h"
#import "HBPackage.h"
#import "HBContactViewController.h"
#include <objc/runtime.h>
#import <version.h>
#import <dlfcn.h>
#import <HBLog.h>
#import <MobileGestalt/MobileGestalt.h>
@import MessageUI;

@implementation HBSupportController

+ (id)linkInstructionForEmailAddress:(NSString *)emailAddress {
	return nil;
}

+ (nullable NSData *)_xmlPlistForPreferencesIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

	// get the preferences
	HBPreferences *preferences = [HBPreferences preferencesForIdentifier:identifier];
	NSDictionary <NSString *, id> *dictionary = preferences.dictionaryRepresentation;

	// if there are none, return nil
	if (dictionary.allKeys.count == 0) {
		return nil;
	}

	// and now we get the data representing an XML plist of the dictionary
	CFErrorRef error = nil;
	NSData *data = (__bridge NSData *)CFPropertyListCreateData(kCFAllocatorDefault, (__bridge CFDictionaryRef)dictionary, kCFPropertyListXMLFormat_v1_0, kNilOptions, &error);

	if (error) {
		HBLogError(@"error serializing prefs for %@: %@", identifier, error);
		return nil;
	}

	return data;
}

+ (UIViewController *)supportViewControllerForBundle:(NSBundle *)bundle {
	return [self supportViewControllerForBundle:bundle preferencesIdentifier:nil sendToEmail:nil];
}

+ (UIViewController *)supportViewControllerForBundle:(nullable NSBundle *)bundle preferencesIdentifier:(nullable NSString *)preferencesIdentifier linkInstruction:(id)linkInstruction supportInstructions:(NSArray *)supportInstructions {
	return [self supportViewControllerForBundle:bundle preferencesIdentifier:preferencesIdentifier sendToEmail:nil];
}

+ (UIViewController *)supportViewControllerForBundle:(nullable NSBundle *)bundle preferencesIdentifier:(nullable NSString *)preferencesIdentifier {
	return [self supportViewControllerForBundle:bundle preferencesIdentifier:preferencesIdentifier sendToEmail:nil];
}

+ (UIViewController *)supportViewControllerForBundle:(nullable NSBundle *)bundle preferencesIdentifier:(nullable NSString *)preferencesIdentifier sendToEmail:(nullable NSString *)sendToEmail {
	NSParameterAssert(preferencesIdentifier ?: bundle);

#if CEPHEI_EMBEDDED
	return nil;
#else
	// Try and figure out what package we have.
	NSString *package = bundle.infoDictionary[@"HBPackageIdentifier"] ?: bundle.bundleIdentifier;
	NSDictionary <NSString *, NSString *> *fields = getFieldsForPackage(package, @[ @"Name", @"Author", @"Maintainer", @"Version" ]);
	NSString *author = sendToEmail ?: fields[@"Author"] ?: fields[@"Maintainer"];
	if (author == nil) {
		// Try something else.
		NSParameterAssert(bundle);
		int status = 0;
		NSString *search = HBOutputForShellCommandWithReturnCode(shellEscape(@[ @"/usr/bin/dpkg-query", @"-S", bundle.executablePath ]), &status);
		NSAssert(status == 0, @"Could not retrieve a package for preferences identifier %@, bundle %@.", preferencesIdentifier, bundle);

		package = [search substringWithRange:NSMakeRange(0, [search rangeOfString:@":"].location)];
		fields = getFieldsForPackage(package, @[ @"Name", @"Author", @"Maintainer", @"Version" ]);
		author = fields[@"Author"] ?: fields[@"Maintainer"];
		NSAssert(author != nil, @"Could not retrieve a package for preferences identifier %@, bundle %@.", preferencesIdentifier, bundle);
	}
	NSAssert([author rangeOfString:@"@"].location != NSNotFound, @"Could not retrieve an email address for package %@.", package);
	NSString *name = fields[@"Name"] ?: package;
	NSString *version = fields[@"Version"];

	HBContactViewController *viewController = [[HBContactViewController alloc] init];
	viewController.to = author;
	viewController.subject = [NSString stringWithFormat:LOCALIZE(@"SUPPORT_EMAIL_SUBJECT", @"Support", @"The subject used when sending a support email. %@ %@ is the package name and version respectively."), name, version];

	NSString *product = nil, *firmware = nil, *build = nil;

	if (IS_IOS_OR_NEWER(iOS_6_0)) {
		void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY);
		CFTypeRef (*myMGCopyAnswer)(CFStringRef question, CFDictionaryRef options);
		myMGCopyAnswer = dlsym(gestalt, "MGCopyAnswer");
		product = CFBridgingRelease(myMGCopyAnswer(kMGProductType, NULL));
		firmware = CFBridgingRelease(myMGCopyAnswer(kMGProductVersion, NULL));
		build = CFBridgingRelease(myMGCopyAnswer(kMGBuildVersion, NULL));
	} else {
		product = [UIDevice currentDevice].localizedModel;
		firmware = [UIDevice currentDevice].systemVersion;
		build = @"?";
	}
	viewController.messageBody = [NSString stringWithFormat:@"\n\nDevice information: %@, iOS %@ (%@)", product, firmware, build];

	// write a plist of the preferences using the identifier we think it may be
	NSString *realPreferencesIdentifier = preferencesIdentifier ?: bundle.bundleIdentifier;
	viewController.preferencesPlist = [self _xmlPlistForPreferencesIdentifier:realPreferencesIdentifier];
	viewController.preferencesIdentifier = realPreferencesIdentifier;
	return viewController;
#endif
}

@end
