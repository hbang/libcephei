#import "HBListController+Actions.h"
#import "../HBRespringController.h"
#import <Preferences/PSTableCell.h>

@interface HBRespringController ()

+ (NSURL *)_preferencesReturnURL;

@end

@implementation HBListController (Actions)

#pragma mark - Respring

- (void)hb_respring:(PSSpecifier *)specifier {
	[self _hb_respringAndReturn:NO specifier:specifier];
}

- (void)hb_respringAndReturn:(PSSpecifier *)specifier {
	[self _hb_respringAndReturn:YES specifier:specifier];
}

- (void)_hb_respringAndReturn:(BOOL)returnHere specifier:(PSSpecifier *)specifier {
	PSTableCell *cell = [self cachedCellForSpecifier:specifier];

	// disable the cell, in case it takes a moment
	cell.cellEnabled = NO;

	// call the main method
	[HBRespringController respringAndReturnTo:returnHere ? [HBRespringController _preferencesReturnURL] : nil];
}

@end
