static NSInteger const kUISliderLabelTag = 0x76616C75;

@interface UISlider ()

- (UILabel *)_hb_valueLabel;
- (void)_hb_showValueEntryPopup;

@end

%hook UISlider

- (void)setShowValue:(BOOL)showValue {
	%orig;

	if (showValue) {
		UILabel *label = self._hb_valueLabel;
		CGRect frame = label.frame;
		frame.size.width += 10;
		label.frame = frame;
		label.font = [UIFont monospacedDigitSystemFontOfSize:label.font.pointSize weight:UIFontWeightRegular];
		label.textColor = self.tintColor;
	}
}

- (void)tintColorDidChange {
	%orig;

	self._hb_valueLabel.textColor = self.tintColor;
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

	// Set up the alert controller. If there is an accessibilityLabel, use that as the title and our
	// title as subtitle. Otherwise, just use our title.
	UIAlertController *alertController = [UIAlertController	alertControllerWithTitle:self.accessibilityLabel ?: title message:self.accessibilityLabel ? title : nil preferredStyle:UIAlertControllerStyleAlert];

	// Insert text box
	[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.keyboardType = UIKeyboardTypeDecimalPad;
		NSString *value = [NSString stringWithFormat:@"%.02f", self.value];
		if ([value hasSuffix:@"0"]) {
			value = [value substringToIndex:value.length - 1];
		}
		if ([value hasSuffix:@".0"]) {
			value = [value substringToIndex:value.length - 3];
		}
		textField.text = value;
	}];

	// Insert buttons
	[alertController addAction:[UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		self.value = alertController.textFields[0].text.floatValue;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];

	[self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

%end
