#import "HBSupportController.h"
#import "../HBPreferences.h"
#import <TechSupport/TechSupport.h>

@implementation HBSupportController

#if !CEPHEI_EMBEDDED
+ (void)initialize {
	[super initialize];

	// lazy load TechSupport.framework
	[[NSBundle bundleWithPath:@"/Library/Frameworks/TechSupport.framework"] load];
}
#endif

+ (TSLinkInstruction *)linkInstructionForEmailAddress:(NSString *)emailAddress {
	NSParameterAssert(emailAddress);

#if CEPHEI_EMBEDDED
	return nil;
#else
	// work around what seems to be a TechSupport bug — the link instruction fails to be parsed if in
	// quotes but without spaces. this can happen if we’re just given a bare email address. we work
	// around it by changing it to the format "Support <jappleseed@example.com>" if no space is found
	if ([emailAddress rangeOfString:@" "].location == NSNotFound) {
		emailAddress = [NSString stringWithFormat:@"Support <%@>", emailAddress];
	}

	return [%c(TSLinkInstruction) instructionWithString:[NSString stringWithFormat:@"link email \"%@\" as \"%@\" is_support", emailAddress, LOCALIZE(@"EMAIL_SUPPORT", @"About", @"Label for a button that allows the user to email the developer.")]];
#endif
}

+ (nullable TSPackage *)_packageForIdentifier:(nullable NSString *)identifier orFile:(nullable NSString *)file {
	NSParameterAssert(identifier ?: file);

#if CEPHEI_EMBEDDED
	return nil;
#else
	if (!%c(TSPackage)) {
		HBLogWarn(@"returning nil package as TechSupport.framework isn’t loaded or failed to load");
		return nil;
	}

	TSPackage *package = nil;

	if (identifier) {
		package = [%c(TSPackage) packageWithIdentifier:identifier];
	}

	if (!package) {
		package = [%c(TSPackage) packageForFile:file];
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
	if (!%c(TSContactViewController)) {
		HBLogWarn(@"returning empty view controller as TechSupport.framework isn’t loaded or failed to load");
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
		[%c(TSIncludeInstruction) instructionWithString:@"include as \"Package List\" command /usr/bin/dpkg -l"],
		[%c(TSIncludeInstruction) instructionWithString:[NSString stringWithFormat:@"include as Preferences plist \"%@\"", prefsPath]]
	];

	NSArray *includeInstructions = supportInstructions ? [builtInInstructions arrayByAddingObjectsFromArray:supportInstructions] : builtInInstructions;

	// if we don’t have a link instruction, make one using the package’s defined
	// author email
	if (!linkInstruction) {
		linkInstruction = [self linkInstructionForEmailAddress:package.author];
	}

	// set up the view controller
	TSContactViewController *viewController = [[%c(TSContactViewController) alloc] initWithPackage:package linkInstruction:linkInstruction includeInstructions:includeInstructions];
	viewController.title = LOCALIZE(@"SUPPORT_TITLE", @"Support", @"Title displayed in the navigation bar of the support page.");
	viewController.subject = [NSString stringWithFormat:LOCALIZE(@"SUPPORT_EMAIL_SUBJECT", @"Support", @"The subject used when sending a support email. %@ %@ is the package name and version respectively."), package.name, package.version];
	viewController.requiresDetailsFromUser = YES;

	return viewController;
#endif
}

@end
