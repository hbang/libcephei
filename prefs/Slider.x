#import "HBDiscreteSliderTableCell.h"
#import <version.h>

static NSInteger const kUISliderLabelTag = 1986096245;

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
		[label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_hb_gestureRecognizerChanged:)]];
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

%new - (void)_hb_gestureRecognizerChanged:(UITapGestureRecognizer *)gestureRecognizer {
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStatePossible:
		case UIGestureRecognizerStateChanged:
			break;

		case UIGestureRecognizerStateBegan:
			[UIView animateWithDuration:0.2 animations:^{
				self._hb_valueLabel.alpha = 0.3f;
			}];
			break;

		case UIGestureRecognizerStateEnded:
			[self _hb_showValueEntryPopup];

		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			[UIView animateWithDuration:0.2 animations:^{
				self._hb_valueLabel.alpha = 1;
			}];
			break;
	}
}

%new - (void)_hb_showValueEntryPopup {
	NSString *title = LOCALIZE(@"ENTER_VALUE", @"Common", @"Title of a prompt that allows typing in a value.");

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
	[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		// set the value, which will fire the value change callback
		self.value = alertController.textFields[0].text.floatValue;
	}]];

	// same for cancel
	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	// grab the root window and display it
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	[window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

%end
