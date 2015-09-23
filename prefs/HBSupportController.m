#import "HBSupportController.h"
#import <TechSupport/TechSupport.h>

@implementation HBSupportController

+ (TSPackage *)packageForIdentifier:(nullable NSString *)identifier orFile:(nullable NSString *)file {
	NSParameterAssert(identifier ?: file);

	if (identifier) {
		return [TSPackage packageWithIdentifier:identifier];
	} else {
		return [TSPackage packageForFile:file];
	}
}

+ (nullable NSData *)xmlPlistForPreferencesIdentifier:(NSString *)identifier {
	NSParameterAssert(identifier);

	CFDictionaryRef prefs = CFPreferencesCopyMultiple(CFPreferencesCopyKeyList((CFStringRef)identifier, CFSTR("mobile"), kCFPreferencesAnyHost), (CFStringRef)identifier, CFSTR("mobile"), kCFPreferencesAnyHost);

	CFErrorRef error = nil;
	NSData *data = (NSData *)CFPropertyListCreateData(kCFAllocatorDefault, prefs, kCFPropertyListXMLFormat_v1_0, kNilOptions, &error);

	if (error) {
		HBLogError(@"error serializing prefs for %@: %@", identifier, error);
		return nil;
	}

	return data;
}

+ (TSContactViewController *)supportViewControllerForBundle:(nullable NSBundle *)bundle preferencesIdentifier:(nullable NSString *)preferencesIdentifier linkInstruction:(nullable TSLinkInstruction *)linkInstruction supportInstructions:(NSArray *)supportInstructions {
	NSParameterAssert(preferencesIdentifier ?: bundle);
	NSParameterAssert(supportInstructions);

	/*
	 get the TSPackage for either the custom package id in Info.plist, falling
	 back to the bundle id. if neither provide a package, the containing package
	 is used. if there's still no TSPackage, throw an assertion.
	*/
	TSPackage *package = [self packageForIdentifier:bundle.infoDictionary[@"HBPackageIdentifier"] ?: bundle.bundleIdentifier orFile:bundle.executablePath];
	NSAssert(package, @"Could not retrieve a package for preferences identifier %@, bundle %@.", preferencesIdentifier, bundle);

	NSString *prefsPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"libcephei-preferences.plist"];

	NSData *plistData = [self xmlPlistForPreferencesIdentifier:preferencesIdentifier ?: bundle.bundleIdentifier];
	[plistData writeToFile:prefsPath atomically:YES];

	NSArray *includeInstructions = [@[
		[TSIncludeInstruction instructionWithString:@"include as \"Package List\" command /usr/bin/dpkg -l"],
		[TSIncludeInstruction instructionWithString:[NSString stringWithFormat:@"include as Preferences plist \"%@\"", prefsPath]]
	] arrayByAddingObjectsFromArray:supportInstructions];

	TSContactViewController *viewController = [[TSContactViewController alloc] initWithPackage:package linkInstruction:linkInstruction includeInstructions:includeInstructions];
	viewController.title = LOCALIZE(@"SUPPORT_TITLE", @"Support", @"Title displayed in the navigation bar of the support page.");
	viewController.subject = [NSString stringWithFormat:LOCALIZE(@"SUPPORT_EMAIL_SUBJECT", @"Support", @"The subject used when sending a support email. %@ %@ is the package name and version respectively."), package.name, package.version];
	viewController.requiresDetailsFromUser = YES;

	return viewController;
}

@end
