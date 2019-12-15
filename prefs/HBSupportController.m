#import "HBSupportController.h"
#import "../HBPreferences.h"
#import "../HBOutputForShellCommand.h"
#import "HBContactViewController.h"
#import <TechSupport/TechSupport.h>
#include <objc/runtime.h>
#import <version.h>
#import <HBLog.h>
#import <MobileGestalt/MobileGestalt.h>
@import MessageUI;

Class $TSPackage, $TSLinkInstruction, $TSIncludeInstruction, $TSContactViewController;

static inline NSString *shellEscape(NSArray <NSString *> *input) {
	NSMutableArray <NSString *> *result = [NSMutableArray array];
	for (NSString *string in input) {
		[result addObject:[NSString stringWithFormat:@"'%@'",
			[string stringByReplacingOccurrencesOfString:@"'" withString:@"\\'" options:NSRegularExpressionSearch range:NSMakeRange(0, string.length)]]];
	}
	return [result componentsJoinedByString:@" "];
}

@implementation HBSupportController

#if !CEPHEI_EMBEDDED
+ (void)initialize {
	[super initialize];

	if (!IS_IOS_OR_NEWER(iOS_13_0)) {
		// lazy load TechSupport.framework
		[[NSBundle bundleWithPath:@"/Library/Frameworks/TechSupport.framework"] load];
		
		$TSPackage = objc_getClass("TSPackage");
		$TSLinkInstruction = objc_getClass("TSLinkInstruction");
		$TSIncludeInstruction = objc_getClass("TSIncludeInstruction");
		$TSContactViewController = objc_getClass("TSContactViewController");
	}
}
#endif

+ (TSLinkInstruction *)linkInstructionForEmailAddress:(NSString *)emailAddress {
	NSParameterAssert(emailAddress);

#if CEPHEI_EMBEDDED
	return nil;
#else
	if ($TSLinkInstruction == nil) {
		HBLogWarn(@"TechSupport is not installed. Returning nil TSLinkInstruction from -[HBSupportController linkInstructionForEmailAddress:].");
		return nil;
	}

	// work around what seems to be a TechSupport bug — the link instruction fails to be parsed if in
	// quotes but without spaces. this can happen if we’re just given a bare email address. we work
	// around it by changing it to the format "Support <jappleseed@example.com>" if no space is found
	if ([emailAddress rangeOfString:@" "].location == NSNotFound) {
		emailAddress = [NSString stringWithFormat:@"Support <%@>", emailAddress];
	}

	return [$TSLinkInstruction instructionWithString:[NSString stringWithFormat:@"link email \"%@\" as \"%@\" is_support", emailAddress, LOCALIZE(@"EMAIL_SUPPORT", @"About", @"Label for a button that allows the user to email the developer.")]];
#endif
}

+ (nullable TSPackage *)_packageForIdentifier:(nullable NSString *)identifier orFile:(nullable NSString *)file {
	NSParameterAssert(identifier ?: file);

#if CEPHEI_EMBEDDED
	return nil;
#else
	if ($TSPackage == nil) {
		HBLogWarn(@"TechSupport is not installed. Returning nil TSPackage.");
		return nil;
	}

	TSPackage *package = nil;

	if (identifier) {
		package = [$TSPackage packageWithIdentifier:identifier];
	}

	if (!package) {
		package = [$TSPackage packageForFile:file];
	}

	return package;
#endif
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

+ (TSContactViewController *)supportViewControllerForBundle:(NSBundle *)bundle {
	return [self supportViewControllerForBundle:bundle preferencesIdentifier:nil linkInstruction:nil supportInstructions:nil];
}

+ (TSContactViewController *)supportViewControllerForBundle:(nullable NSBundle *)bundle preferencesIdentifier:(NSString *)preferencesIdentifier {
	return [self supportViewControllerForBundle:bundle preferencesIdentifier:preferencesIdentifier linkInstruction:nil supportInstructions:nil];
}

+ (TSContactViewController *)supportViewControllerForBundle:(nullable NSBundle *)bundle preferencesIdentifier:(nullable NSString *)preferencesIdentifier linkInstruction:(TSLinkInstruction *)linkInstruction supportInstructions:(NSArray <TSIncludeInstruction *> *)supportInstructions {
	NSParameterAssert(preferencesIdentifier ?: bundle);

#if CEPHEI_EMBEDDED
	return nil;
#else
	// libpackageinfo is broken on iOS 13. We need to avoid using it for now.
	if ($TSContactViewController == nil || IS_IOS_OR_NEWER(iOS_13_0)) {
		HBLogWarn(@"TechSupport is not installed. Using MFMailComposeViewController instead. linkInstruction and supportInstructions are ignored.");

		// No use doing this if we can’t send email.
		if (![MFMailComposeViewController canSendMail]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No mail accounts are set up." message:@"Use the Mail settings to add a new account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			return nil;
		}

		// Try and figure out what package we have.
		NSString *package = bundle.infoDictionary[@"HBPackageIdentifier"] ?: bundle.bundleIdentifier;
		int status;
		NSString *author = HBOutputForShellCommandWithReturnCode(shellEscape(@[ @"/usr/bin/dpkg-query", @"-Wf", @"${Author}", package ]), &status);
		if (status != 0 || [author isEqualToString:@""]) {
			// Try something else.
			NSParameterAssert(bundle);
			NSString *search = HBOutputForShellCommandWithReturnCode(shellEscape(@[ @"/usr/bin/dpkg-query", @"-S", bundle.executablePath ]), &status);
			NSAssert(status == 0, @"Could not retrieve a package for preferences identifier %@, bundle %@.", preferencesIdentifier, bundle);
			package = [search substringWithRange:NSMakeRange(0, [search rangeOfString:@":"].location)];
			author = HBOutputForShellCommandWithReturnCode(shellEscape(@[ @"/usr/bin/dpkg-query", @"-Wf", @"${Author}", package ]), &status);
			NSAssert(status == 0, @"Could not retrieve a package for preferences identifier %@, bundle %@.", preferencesIdentifier, bundle);
		}
		NSAssert([author rangeOfString:@"@"].location != NSNotFound, @"Could not retrieve an email address for package %@.", package);
		NSString *name = HBOutputForShellCommandWithReturnCode(shellEscape(@[ @"/usr/bin/dpkg-query", @"-Wf", @"${Name}", package ]), &status);
		if ([name isEqualToString:@""]) {
			name = package;
		}
		NSString *version = HBOutputForShellCommandWithReturnCode(shellEscape(@[ @"/usr/bin/dpkg-query", @"-Wf", @"${Version}", package ]), &status);

		HBContactViewController *viewController = [[HBContactViewController alloc] init];
		viewController.to = author;
		viewController.subject = [NSString stringWithFormat:LOCALIZE(@"SUPPORT_EMAIL_SUBJECT", @"Support", @"The subject used when sending a support email. %@ %@ is the package name and version respectively."), name, version];

		NSString *product = nil, *firmware = nil, *build = nil;

		if (IS_IOS_OR_NEWER(iOS_6_0)) {
			product = CFBridgingRelease(MGCopyAnswer(kMGProductType, NULL));
			firmware = CFBridgingRelease(MGCopyAnswer(kMGProductVersion, NULL));
			build = CFBridgingRelease(MGCopyAnswer(kMGBuildVersion, NULL));
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
		return (TSContactViewController *)viewController;
	}

	// get the TSPackage for either the custom package id in Info.plist, falling back to the bundle
	// id. if neither provide a package, the containing package is used. if there’s still no
	// TSPackage, throw an assertion.
	TSPackage *package = [self _packageForIdentifier:bundle.infoDictionary[@"HBPackageIdentifier"] ?: bundle.bundleIdentifier orFile:bundle.executablePath];
	NSAssert(package, @"Could not retrieve a package for preferences identifier %@, bundle %@.", preferencesIdentifier, bundle);

	NSString *realPreferencesIdentifier = preferencesIdentifier ?: bundle.bundleIdentifier;

	// write a plist of the preferences using the identifier we think it may be
	NSString *prefsPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"preferences-%@.plist", realPreferencesIdentifier]];

	NSData *plistData = [self _xmlPlistForPreferencesIdentifier:realPreferencesIdentifier];
	[plistData writeToFile:prefsPath atomically:YES];

	// construct the support instructions
	NSArray <TSIncludeInstruction *> *builtInInstructions = @[
		[$TSIncludeInstruction instructionWithString:@"include as \"Package List\" command /usr/bin/dpkg -l"],
		[$TSIncludeInstruction instructionWithString:[NSString stringWithFormat:@"include as Preferences plist \"%@\"", prefsPath]]
	];

	NSArray *includeInstructions = supportInstructions ? [builtInInstructions arrayByAddingObjectsFromArray:supportInstructions] : builtInInstructions;

	// if we don’t have a link instruction, make one using the package’s defined
	// author email
	if (!linkInstruction) {
		linkInstruction = [self linkInstructionForEmailAddress:package.author];
	}

	// set up the view controller
	TSContactViewController *viewController = [[$TSContactViewController alloc] initWithPackage:package linkInstruction:linkInstruction includeInstructions:includeInstructions];
	viewController.title = LOCALIZE(@"SUPPORT_TITLE", @"Support", @"Title displayed in the navigation bar of the support page.");
	viewController.subject = [NSString stringWithFormat:LOCALIZE(@"SUPPORT_EMAIL_SUBJECT", @"Support", @"The subject used when sending a support email. %@ %@ is the package name and version respectively."), package.name, package.version];
	viewController.requiresDetailsFromUser = YES;

	return viewController;
#endif
}

@end
