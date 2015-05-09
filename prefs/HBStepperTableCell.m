#import "HBStepperTableCell.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIColor+Private.h>
#import <UIKit/UIImage+Private.h>
#import <version.h>

extern NSString *const PSControlMinimumKey;
extern NSString *const PSControlMaximumKey;

static NSString *const kHBStepperTableCellSingularLabelKey = @"singularLabel";

@implementation HBStepperTableCell

@dynamic control;

#pragma mark - UITableViewCell

- (void)prepareForReuse {
	[super prepareForReuse];

	self.control.value = 0;
	self.control.minimumValue = 0;
	self.control.maximumValue = 100;
}

#pragma mark - PSTableCell

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
	[super refreshCellContentsWithSpecifier:specifier];

	self.control.minimumValue = ((NSNumber *)specifier.properties[PSControlMinimumKey]).doubleValue;
	self.control.maximumValue = ((NSNumber *)specifier.properties[PSControlMaximumKey]).doubleValue;
	[self _updateLabel];
}

- (void)setCellEnabled:(BOOL)cellEnabled {
	[super setCellEnabled:cellEnabled];
	self.control.enabled = cellEnabled;
}

#pragma mark - PSControlTableCell

- (UIStepper *)newControl {
	UIStepper *stepper = [[UIStepper alloc] init];
	stepper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	stepper.continuous = NO;
	stepper.center = CGPointMake(stepper.center.x, self.frame.size.height / 2);

	// i assume this is what i'm meant to do?
	CGRect frame = stepper.frame;
	frame.origin.x = self.contentView.frame.size.width - frame.size.width - 15.f;
	stepper.frame = frame;

	return stepper;
}

- (NSNumber *)controlValue {
	return @(self.control.value);
}

- (void)setValue:(NSNumber *)value {
	[super setValue:value];
	self.control.value = value.doubleValue;
}

- (void)controlChanged:(UIStepper *)stepper {
	[super controlChanged:stepper];
	[self _updateLabel];
}

- (void)_updateLabel {
	if (!self.control) {
		return;
	}

	self.textLabel.text = self.control.value == 1 ? self.specifier.properties[kHBStepperTableCellSingularLabelKey] : [NSString stringWithFormat:self.specifier.name, (int)self.control.value];
	[self setNeedsLayout];
}

@end
