%hook UISlider

- (void)_layoutSubviewsForBoundsChange:(BOOL)something {
	%orig;

	UILabel *label = (UILabel *)[self viewWithTag:1986096245];
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

%end
