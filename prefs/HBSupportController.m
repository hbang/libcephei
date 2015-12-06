#import "HBSupportController.h"
#import <TechSupport/TechSupport.h>

@implementation HBSupportController

+ (TSLinkInstruction *)linkInstructionForEmailAddress:(NSString *)emailAddress {
	NSParameterAssert(emailAddress);

	return [TSLinkInstruction instructionWithString:[NSString stringWithFormat:@"link email \"%@\" as \"%@\" is_support", emailAddress, LOCALIZE(@"EMAIL_SUPPORT", @"About", @"Label for a button that allows the user to email the developer.")]];
}

+ (TSPackage *)_packageForIdentifier:(nullable NSString *)identifier orFile:(nullable NSString *)file {
	NSParameterAssert(identifier ?: file);

	if (identifier) {
		return [TSPackage packageWithIdentifier:identifier];
	} else {
		return [TSPackage packageForFile:file];
	}
}

+ (nullable NSData *)_xmlPlistForPreferencesIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

	// get the keys in the plist
	CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)identifier, CFSTR("mobile"), kCFPreferencesAnyHost);

	// if there are no keys, return nil
	if (!keyList) {
		return nil;
	}

	// now we can get the values for the keys
	CFDictionaryRef prefs = CFPreferencesCopyMultiple(keyList, (CFStringRef)identifier, CFSTR("mobile"), kCFPreferencesAnyHost);
	CFRelease(keyList);

	// and now we get the data representing an XML plist of the dictionary
	CFErrorRef error = nil;
	NSData *data = [(NSData *)CFPropertyListCreateData(kCFAllocatorDefault, prefs, kCFPropertyListXMLFormat_v1_0, kNilOptions, &error) autorelease];
	CFRelease(prefs);

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

+ (TSContactViewController *)supportViewControllerForBundle:(nullable NSBundle *)bundle preferencesIdentifier:(nullable NSString *)preferencesIdentifier linkInstruction:(TSLinkInstruction *)linkInstruction supportInstructions:(NSArray <TSInstruction *> *)supportInstructions {
	NSParameterAssert(preferencesIdentifier ?: bundle);

	/*
	 get the TSPackage for either the custom package id in Info.plist, falling
	 back to the bundle id. if neither provide a package, the containing package
	 is used. if there's still no TSPackage, throw an assertion.
	*/
	TSPackage *package = [self _packageForIdentifier:bundle.infoDictionary[@"HBPackageIdentifier"] ?: bundle.bundleIdentifier orFile:bundle.executablePath];
	NSAssert(package, @"Could not retrieve a package for preferences identifier %@, bundle %@.", preferencesIdentifier, bundle);

	// write a plist of the preferences using the identifier we think it may be
	NSString *prefsPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"libcephei-preferences.plist"];

	NSData *plistData = [self _xmlPlistForPreferencesIdentifier:preferencesIdentifier ?: bundle.bundleIdentifier];
	[plistData writeToFile:prefsPath atomically:YES];

	// construct the support instructions
	NSArray *builtInInstructions = @[
		[TSIncludeInstruction instructionWithString:@"include as \"Package List\" command /usr/bin/dpkg -l"],
		[TSIncludeInstruction instructionWithString:[NSString stringWithFormat:@"include as Preferences plist \"%@\"", prefsPath]]
	];

	NSArray *includeInstructions = supportInstructions ? [builtInInstructions arrayByAddingObjectsFromArray:supportInstructions] : builtInInstructions;

	// if we don’t have a link instruction, make one using the package’s defined
	// author email
	if (!linkInstruction) {
		linkInstruction = [self linkInstructionForEmailAddress:package.author];
	}

	// set up the view controller
	TSContactViewController *viewController = [[TSContactViewController alloc] initWithPackage:package linkInstruction:linkInstruction includeInstructions:includeInstructions];
	viewController.title = LOCALIZE(@"SUPPORT_TITLE", @"Support", @"Title displayed in the navigation bar of the support page.");
	viewController.subject = [NSString stringWithFormat:LOCALIZE(@"SUPPORT_EMAIL_SUBJECT", @"Support", @"The subject used when sending a support email. %@ %@ is the package name and version respectively."), package.name, package.version];
	viewController.requiresDetailsFromUser = YES;

	return viewController;
}

@end
