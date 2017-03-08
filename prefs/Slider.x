#import "HBDiscreteSliderTableCell.h"
#import <version.h>

static NSInteger const kUISliderLabelTag = 0x76616C75;

@interface UISlider ()

- (UILabel *)_hb_valueLabel;
- (void)_hb_showValueEntryPopup;

@end

%hook UISlider

- (void)setShowValue:(BOOL)showValue {
	%orig;

	if (showValue && IS_IOS_OR_NEWER(iOS_8_0)) {
		UILabel *label = self._hb_valueLabel;
		label.textColor = self.tintColor;
	}
}

- (void)tintColorDidChange {
	%orig;

	self._hb_valueLabel.textColor = self.tintColor;
}

- (void)_layoutSubviewsForBoundsChange:(BOOL)something {
	%orig;

	// from iOS 2(?) to 6, the label is strangely positioned. the cause is just a
	// missing autoresizeMask. fix that here
	if (!IS_IOS_OR_NEWER(iOS_7_0)) {
		self._hb_valueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	}
}

%new - (UILabel *)_hb_valueLabel {
	return [self viewWithTag:kUISliderLabelTag];
}

- (void)touchesEnded:(NSSet <UITouch *> *)touches withEvent:(UIEvent *)event {
	%orig;

	UITouch *touch = touches.anyObject;

	if (CGRectContainsPoint(CGRectInset(self._hb_valueLabel.frame, -10, -15), [touch locationInView:self])) {
		[self _hb_showValueEntryPopup];
	}
}

%new - (void)_hb_showValueEntryPopup {
	NSString *title = LOCALIZE(@"ENTER_VALUE", @"Common", @"Title of a prompt that allows typing in a value.");

	NSBundle *uikitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
	NSString *ok = [uikitBundle localizedStringForKey:@"OK" value:@"" table:@"Localizable"];
	NSString *cancel = [uikitBundle localizedStringForKey:@"Cancel" value:@"" table:@"Localizable"];

	// set up the alert controller. if there is an accessibilityLabel, use that
	// as the title and our title as subtitle. otherwise, just use our title
	UIAlertController *alertController = [UIAlertController	alertControllerWithTitle:self.accessibilityLabel ?: title message:self.accessibilityLabel ? title : nil preferredStyle:UIAlertControllerStyleAlert];

	// insert our text box
	[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		// set to a decimal pad keyboard
		textField.keyboardType = UIKeyboardTypeDecimalPad;

		// limit to 2 decimal places, because floats are fun
		textField.text = [NSString stringWithFormat:@"%.02f", self.value];
	}];

	// insert our ok button
	[alertController addAction:[UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		// set the value
		self.value = alertController.textFields[0].text.floatValue;

		// fire the callback so it gets stored
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}]];

	// same for cancel
	[alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];

	// grab the root window and display it
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	[window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

%end
